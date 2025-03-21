//
//  PubSubManager.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import Foundation

// MARK: - Notification names
extension Notification.Name {
	public static let PubSubMessage = Notification.Name("PubSubMessage")
}

class PubSubManager: ObservableObject {
	
	static let shared = PubSubManager()
	
	@Published var isConnected = false
	
	private var webSocketTask: URLSessionWebSocketTask?
	private let urlSession: URLSession
	private var retryCount = 0
	private let maxRetries = 5
	private let retryDelay: TimeInterval = 5
	
	private let subManager = SubscriptionManager()
	
	// System logger
	let logger = LogUtils.createLogger(tag: "PubSubManager")
	
	init() {
		self.urlSession = URLSession(configuration: .default)
		self.setupSubscribers()
		
		if UserCfg.isLoggedIn() {
			self.connect()
		}
	}
	
	// Connect to the WebSocket server
	func connect() {
		guard let token = UserCfg.sessionToken() else {
			self.logger.warning("No session token found for user")
			return
		}
		
		var request = URLRequest(url: APICfg.wsUrl)
		request.addValue(APICfg.wsApiKey, forHTTPHeaderField: "X-API-Key") // Add API key header
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		self.webSocketTask = urlSession.webSocketTask(with: request)
		self.webSocketTask?.resume()
		self.isConnected = true
		self.retryCount = 0 // Reset retry count on successful connection
		
		self.receiveMessages() // Start receiving messages
	}
	
	// Disconnect from the WebSocket server
	func disconnect() {
		self.webSocketTask?.cancel(with: .goingAway, reason: nil)
		self.webSocketTask = nil
		self.isConnected = false
	}
	
	// Send a message to the WebSocket server
	func sendMessage(_ message: String) {
		let message = URLSessionWebSocketTask.Message.string(message)
		self.webSocketTask?.send(message) { error in
			if let error = error {
				print("Failed to send message: \(error)")
			}
		}
	}
	
	// Receive messages from the WebSocket server
	private func receiveMessages() {
		self.webSocketTask?.receive { [weak self] result in
			switch result {
			case .success(let message):
				switch message {
				case .string(let text):
					self?.processMessage(text)
				case .data(let data):
					self?.processMessage(data)
				@unknown default:
					print("Unknown message type")
				}
			case .failure(let error):
				self?.logger.error("Failed to receive message: \(error)")
				self?.handleDisconnection() // Handle disconnection on failure
				return
			}
			
			// Continue receiving messages
			self?.receiveMessages()
		}
	}
	
	// Handle disconnection and retry logic
	private func handleDisconnection() {
		self.isConnected = false
		self.webSocketTask = nil
		
		if self.retryCount < self.maxRetries {
			self.retryCount += 1
			print("Attempting to reconnect... (\(self.retryCount)/\(self.maxRetries))")
			DispatchQueue.global().asyncAfter(deadline: .now() + self.retryDelay) {
				self.connect()
			}
		} else {
			print("Max retry attempts reached. Could not reconnect to WebSocket.")
		}
	}
	
	private func processMessage(_ text: String) {
		self.logger.info("Proccessing message \(text)")
		
		if let jsonData = text.data(using: .utf8) {
			self.processMessage(jsonData)
		}
	}
	
	private func processMessage(_ data: Data) {
		do {
			let message = try JSONDecoder().decode(PubSubMessage.self, from: data)
			self.postNotification(message: message)
		}
		catch {
			print("Failed to decode JSON:", error)
		}
	}
	
	fileprivate func postNotification(message: PubSubMessage) {
		self.logger.info("Notifying users \(message.description)")
		
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name.PubSubMessage, object: message)
		}
	}
	
	private func setupSubscribers() {
		Task {
			await NotificationCenter.default.publisher(for: Notification.Name.CfgChanged)
				.receive(on: DispatchQueue.main)
				.compactMap { $0.object as? CfgPayload }
				.sink(receiveValue: { payload in
					if payload.cfgType == .sessionToken {
						if UserCfg.isLoggedIn() {
							self.connect()
						}
						else {
							self.disconnect()
						}
					}
				})
				.storeIn(self.subManager)
		}
	}
}

enum PubSubMessageChannel: String, Codable {
	case conversations
	case messages
}

enum PubSubMessageStatus: String, Codable {
	case create
	case update
	case delete
	case typing
}

enum PubSubMessageStatusSecondary: String, Codable {
	case liked
	case unliked
	case leave
	case read
	case edit
}

struct PubSubMessage : Codable {
	
	let channel: PubSubMessageChannel
	let status: PubSubMessageStatus
	let secondary_status: PubSubMessageStatusSecondary?
	let user_id: Int?
	let conversation_id: Int?
	let message_id: Int?
	let typing: Bool?
	let reason: String?
	
	var description: String {
		var messageBuilder = "[\(self.channel)] [\(self.status)] -"
		if let secondaryStatus = self.secondary_status {
			messageBuilder += " secondaryStatus=\(secondaryStatus),"
		}
		if let reason = self.reason {
			messageBuilder += " reason=\(reason),"
		}
		if let userId = self.user_id {
			messageBuilder += " userId=\(userId),"
		}
		if let conversationId = self.conversation_id {
			messageBuilder += " conversationId=\(conversationId),"
		}
		if let messageId = self.message_id {
			messageBuilder += " messageId=\(messageId),"
		}
		if let typing = self.typing {
			messageBuilder += " typing=\(typing),"
		}
		return messageBuilder
	}
}
