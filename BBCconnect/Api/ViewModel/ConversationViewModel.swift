//
//  ConversationViewModel.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import Foundation
import Combine

class MockConversationsViewModel: ConversationsViewModel {
	init() {
		super.init()
		self.conversations = Conversation.sampleConversations
		self.loadingState = .success(Conversation.sampleConversations)
	}
}

class MockConversationViewModel: ConversationViewModel {
	init() {
		super.init(conversation: Conversation.sampleConversations[0])
		self.messages = ConversationMessage.sampleMessages
		self.loadingState = .success(ConversationMessage.sampleMessages)
	}
}

@MainActor
class ConversationsViewModel: ObservableObject {
	
	static let shared = ConversationsViewModel(includeDeleted: false)
	
	@Published var conversations = [Conversation]()
	@Published var loadingState: APIResult<[Conversation]> = .none
	
	private let subManager = SubscriptionManager()
	private let includeDeleted: Bool
	
	init(includeDeleted: Bool = false) {
		self.includeDeleted = includeDeleted
		
		Task {
			await self.fetchConversations()
		}
		
		self.setupSubscribers()
	}
	
	func fetchConversations() async {
		let queryParams = ["include_deleted": self.includeDeleted]
		
		self.loadingState = .loading
		let result: APIResult<[Conversation]> = await APIManager.shared.request(endpoint: .getConversations,
																				queryParams: queryParams)
		
		DispatchQueue.main.async {
			if case .success(let data) = result {
				self.conversations = data.sorted {
					($0.last_message.createdAtDate ?? Date()) > ($1.last_message.createdAtDate ?? Date())
				}
			}
			
			self.loadingState = result
		}
	}
	
	func createConversation(name: String, users: [User], message: String) async -> (Conversation?, String?) {
		let result: APIResult<Conversation> = await APIManager.shared.request(endpoint: .createConversation,
																			  body: ConversationCreate(name: name,
																									   message: message,
																									   user_ids: users.map { $0.id }))
		
		if case .success(let data) = result {
			return (data, nil)
		}
		else if case .failure(let error) = result {
			return (nil, error.localizedDescription)
		}
		
		return (nil, nil)
	}
	
	func deleteConversation(conversationId: Int) async -> String? {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .deleteConversation(conversationId))
		
		if case .success(_) = result {
			self.conversations.removeAll(where: { $0.id == conversationId })
		}
		else if case .failure(let error) = result {
			return error.localizedDescription
		}
		
		return nil
	}
	
	func leaveConversation(conversationId: Int) async -> String? {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .leaveConversation(conversationId))
		if case .success(_) = result {
			self.conversations.removeAll(where: { $0.id == conversationId })
		}
		else if case .failure(let error) = result {
			return error.localizedDescription
		}
		
		return nil
	}
	
	private func setupSubscribers() {
		Task {
			await NotificationCenter.default.publisher(for: Notification.Name.PubSubMessage)
				.receive(on: DispatchQueue.main)
				.compactMap { $0.object as? PubSubMessage }
				.sink(receiveValue: { payload in
					guard payload.channel == .conversations || payload.channel == .messages else { return }
					if let conversationId = payload.conversation_id, payload.status != .typing {
						if payload.channel == .conversations, let secondaryStatus = payload.secondary_status, secondaryStatus == .leave, payload.user_id == UserCfg.userId() {
							self.conversations.removeAll(where: { $0.id == payload.conversation_id })
						}
						else {
							self.onConversationUpdated(status: payload.channel == .messages ? .update : payload.status,
													   conversationId: conversationId)
						}
					}
				})
				.storeIn(self.subManager)
		}
	}
	
	private func onConversationUpdated(status: PubSubMessageStatus, conversationId: Int) {
		if status == .delete {
			self.conversations.removeAll(where: { $0.id == conversationId })
			return
		}
		
		Task {
			let result: APIResult<Conversation> = await APIManager.shared.request(endpoint: .getConversation(conversationId))
			if case .success(let data) = result {
				DispatchQueue.main.async {
					switch status{
					case .create:
						if self.conversations.first(where: { $0.id == conversationId }) == nil {
							self.conversations.insert(data, at: 0)
						}
					case .update:
						if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
							self.conversations[index] = data
							self.conversations.sort {
								($0.last_message.createdAtDate ?? Date()) > ($1.last_message.createdAtDate ?? Date())
							}
							self.objectWillChange.send()
						}
					default:
						break
					}
				}
			}
		}
	}
}

@MainActor
class ConversationViewModel: ObservableObject {
	
	@Published private(set) var conversation: Conversation
	
	@Published var messages = [ConversationMessage]()
	@Published var loadingState: APIResult<[ConversationMessage]> = .none
	@Published var userTyping: User?
	
	private let subManager = SubscriptionManager()
	private let includeDeleted: Bool
	
	init(conversation: Conversation, includeDeleted: Bool = false) {
		self.conversation = conversation
		self.includeDeleted = includeDeleted
		
		Task {
			await self.fetchMessages()
		}
		
		self.setupSubscribers()
	}
	
	func fetchConversation() {
		Task {
			let result: APIResult<Conversation> = await APIManager.shared.request(endpoint: .getConversation(self.conversation.id))
			if case .success(let data) = result {
				DispatchQueue.main.async {
					self.conversation = data
				}
			}
		}
	}
	
	func addUsersToConversation(newUsers: [User]) async -> (Bool, String?) {
		var users = self.conversation.users
		users.append(contentsOf: newUsers)
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .updateConversation(self.conversation.id), body: ConversationUpdate(name: nil, user_ids: users.map { $0.id }))
		
		if case .success(_) = result {
			return (true, nil)
		}
		else if case .failure(let error) = result {
			return (false, error.localizedDescription)
		}
		
		return (false, nil)
	}
	
	func fetchMessages() async {
		let queryParams = ["include_deleted": self.includeDeleted]
		
		self.loadingState = .loading
		let result: APIResult<[ConversationMessage]> = await APIManager.shared.request(endpoint: .getMessages(self.conversation.id),
																					   queryParams: queryParams)
		
		DispatchQueue.main.async {
			if case .success(let data) = result {
				self.messages = data
			}
			
			self.loadingState = result
		}
	}
	
	func createMessage(message: String) async -> String? {
		let result: APIResult<ConversationMessage> = await APIManager.shared.request(endpoint: .createMessage(self.conversation.id),
																					 body: ConversationMessageCreate(content: message))
		
		if case .success(let data) = result {
			DispatchQueue.main.async {
				self.messages.append(data)
			}
		}
		else if case .failure(let error) = result {
			return error.localizedDescription
		}
		
		return nil
	}
	
	func updateLikedStatus(messageId: Int, liked: Bool) async -> String {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: liked ? .likeMessage(self.conversation.id, messageId) : .unlikeMessage(self.conversation.id, messageId))
		
		if case .success(let data) = result {
			return data.message
		}
		else if case .failure(let error) = result {
			return error.localizedDescription
		}
		
		return "An unknown error occurred"
	}
	
	func deleteMessage(messageId: Int) async -> String? {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .deleteMessage(self.conversation.id, messageId))
		
		if case .success(_) = result {
			self.messages.removeAll(where: { $0.id == messageId })
		}
		else if case .failure(let error) = result {
			return error.localizedDescription
		}
		
		return nil
	}
	
	func leaveConversation() async -> (Bool, String) {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .leaveConversation(self.conversation.id))
		
		if case .success(let data) = result {
			return (true, data.message)
		}
		else if case .failure(let error) = result {
			return (false, error.localizedDescription)
		}
		
		return (false, "An unknown error occurred")
	}
	
	func setTyping(typing: Bool) {
		Task {
			let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .typingConversation(self.conversation.id), body: TypingIndicator(typing: typing))
			
			if case .failure(_) = result {
				// log error?
			}
		}
	}
	
	func markAsRead() async {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .markConversationRead(self.conversation.id))
		
		if case .failure(_) = result {
			// log error?
		}
	}
	
	private func setupSubscribers() {
		Task {
			await NotificationCenter.default.publisher(for: Notification.Name.PubSubMessage)
				.receive(on: DispatchQueue.main)
				.compactMap { $0.object as? PubSubMessage }
				.sink(receiveValue: { payload in
					guard payload.channel == .conversations || payload.channel == .messages else { return }
					if payload.status == .typing {
						self.checkTyping(payload)
					}
					else if let conversationId = payload.conversation_id, conversationId == self.conversation.id {
						if payload.channel == .messages, let messageId = payload.message_id {
							self.onMessageCreatedOrUpdated(status: payload.status,
														   conversationId: conversationId,
														   messageId: messageId)
						}
						else {
							self.onConversationUpdated(status: payload.status, conversationId: conversationId)
						}
					}
				})
				.storeIn(self.subManager)
		}
	}
	
	private func checkTyping(_ payload: PubSubMessage) {
		var userTyping: User? = nil
		if payload.typing == true && payload.conversation_id == self.conversation.id {
			if payload.user_id != UserCfg.userId() {
				userTyping = self.conversation.users.first(where: { $0.id == payload.user_id })
			}
		}
		
		self.userTyping = userTyping
	}
	
	private func onConversationUpdated(status: PubSubMessageStatus, conversationId: Int) {
		guard self.conversation.id == conversationId else { return }
		
		Task {
			let result: APIResult<Conversation> = await APIManager.shared.request(endpoint: .getConversation(conversationId))
			if case .success(let data) = result {
				DispatchQueue.main.async {
					switch status {
					case .update:
						self.conversation = data
					default:
						break
					}
				}
			}
		}
	}
	
	private func onMessageCreatedOrUpdated(status: PubSubMessageStatus, conversationId: Int, messageId: Int) {
		if status == .delete {
			self.messages.removeAll(where: { $0.id == messageId })
			return
		}
		
		// Set false someone typing so we get clean animation
		self.userTyping = nil
		
		Task {
			let result: APIResult<ConversationMessage> = await APIManager.shared.request(endpoint: .getMessage(conversationId, messageId))
			if case .success(let data) = result {
				DispatchQueue.main.async {
					switch status{
					case .create:
						if self.messages.first(where: { $0.id == messageId }) == nil {
							self.messages.append(data)
						}
					case .update:
						if let index = self.messages.firstIndex(where: { $0.id == messageId }) {
							self.messages[index] = data
						}
					default:
						break
					}
				}
			}
		}
	}
}


@MainActor
class NewConversationViewModel: UserSearchViewModel {
	
	@Published var loadingState: APIResult<Conversation> = .none
	
	func createConversation(title: String = "Conversation", users: [User], message: String) async -> (Conversation?, String?) {
		guard !message.isEmpty else {
			return (nil, "You must enter a message")
		}
		
		DispatchQueue.main.async {
			self.loadingState = .loading
		}
		
		let result: APIResult<Conversation> = await APIManager.shared.request(endpoint: .createConversation,
																			  body: ConversationCreate(name: title,
																									   message: message,
																									   user_ids: users.map { $0.id }))
		
		if case .success(let data) = result {
			return (data, nil)
		}
		else if case .failure(let error) = result {
			return (nil, error.localizedDescription)
		}
		
		DispatchQueue.main.async {
			self.loadingState = result
		}
		
		return (nil, nil)
	}
}

fileprivate struct TypingIndicator: Codable {
	let typing: Bool
}
