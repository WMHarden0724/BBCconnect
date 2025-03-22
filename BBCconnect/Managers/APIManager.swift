//
//  APIManager.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine
import os

// MARK: Cfg
public struct APICfg {
	
	// Production URL - comment out when locally testing
	//	public static let baseURL = URL(string: "https://your-api.com/api")!
	// Local testing url - uncomment when locally testing
	public static let baseURL = URL(string: "https://6a14-64-239-42-24.ngrok-free.app")!
	public static var wsUrl: URL {
		return URL(string: "\(Self.baseURL.absoluteString.replacingOccurrences(of: "http", with: "ws"))/ws")!
	}
	
	public static let wsApiKey = "ed287191bcfc7318e4dfb34431c1fff51a03d704f415d886f9fd1cb694a016f0"
}

// MARK: - API Error Enum with detailed descriptions
public enum APIError: Error, LocalizedError, Equatable {
	case invalidURL
	case invalidResponse
	case noData
	case encodingFailed
	case decodingFailed(error: DecodingError)
	case networkError(String)
	case httpError(statusCode: Int)
	case apiError(String)
	
	public var errorDescription: String? {
		switch self {
		case .invalidURL: return "Invalid URL"
		case .invalidResponse: return "Invalid response from server"
		case .noData: return "No data received"
		case .encodingFailed: return "Failed to encode request body"
		case .decodingFailed(let error): return "Decoding error: \(error.localizedDescription)"
		case .networkError(let message): return "Network error: \(message)"
		case .httpError(let statusCode): return "HTTP error: \(statusCode)"
		case .apiError(let message): return message
		}
	}
	
	// Make it conform to Equatable
	public static func == (lhs: APIError, rhs: APIError) -> Bool {
		switch (lhs, rhs) {
		case (.invalidURL, .invalidURL),
			(.invalidResponse, .invalidResponse),
			(.noData, .noData),
			(.encodingFailed, .encodingFailed):
			return true
		case (.decodingFailed(let l), .decodingFailed(let r)):
			return l.localizedDescription == r.localizedDescription
		case (.networkError(let l), .networkError(let r)),
			(.apiError(let l), .apiError(let r)):
			return l == r
		case (.httpError(let l), .httpError(let r)):
			return l == r
		default:
			return false
		}
	}
}

// MARK: - API result handling states
enum APIResult<T: Equatable>: Equatable {
	case none
	case loading
	case success(T)
	case failure(APIError)
	
	var isLoading: Bool {
		if case .loading = self {
			return true
		}
		
		return false
	}
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
}

enum APIEndpoint: Equatable {
	case createUser
	case login
	case forgotPassword
	case userProfile
	case updateUserProfile
	case createConversation
	case getConversations
	case getConversation(Int)
	case updateConversation(Int)
	case deleteConversation(Int)
	case leaveConversation(Int)
	case muteConversation(Int)
	case markConversationRead(Int)
	case typingConversation(Int)
	case getMessages(Int)
	case getMessage(Int, Int)
	case createMessage(Int)
	case deleteMessage(Int, Int)
	case likeMessage(Int, Int)
	case unlikeMessage(Int, Int)
	case searchUsers
	
	var path: String {
		switch self {
		case .createUser: return "/api/users/create"
		case .login: return "/api/users/login"
		case .forgotPassword: return "/api/users/forgot-password"
		case .userProfile: return "/api/users/profile"
		case .updateUserProfile: return "/api/users/profile"
		case .searchUsers: return "/api/users/search"
		case .createConversation: return "/api/conversations"
		case .getConversations: return "/api/conversations"
		case .getConversation(let id): return "/api/conversations/\(id)"
		case .updateConversation(let id): return "/api/conversations/\(id)"
		case .deleteConversation(let id): return "/api/conversations/\(id)"
		case .leaveConversation(let id): return "/api/conversations/\(id)/leave"
		case .muteConversation(let id): return "/api/conversations/\(id)/mute"
		case .markConversationRead(let id): return "/api/conversations/\(id)/read"
		case .typingConversation(let id): return "/api/conversations/\(id)/typing"
		case .createMessage(let id): return "/api/conversations/\(id)/messages"
		case .getMessages(let id): return "/api/conversations/\(id)/messages"
		case .getMessage(let cid, let id): return "/api/conversations/\(cid)/messages/\(id)"
		case .deleteMessage(let cid, let id): return "/api/conversations/\(cid)messages/\(id)"
		case .likeMessage(let cid, let id): return "/api/conversations/\(cid)/messages/\(id)/like"
		case .unlikeMessage(let cid, let id): return "/api/conversations/\(cid)/messages/\(id)/like"
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .createUser: return .post
		case .login: return .post
		case .forgotPassword: return .post
		case .userProfile: return .get
		case .updateUserProfile: return .put
		case .searchUsers: return .get
		case .createConversation: return .post
		case .getConversations: return .get
		case .getConversation(_): return .get
		case .updateConversation(_): return .put
		case .deleteConversation(_): return .delete
		case .leaveConversation(_): return .delete
		case .muteConversation(_): return .post
		case .markConversationRead(_): return .post
		case .typingConversation(_): return .post
		case .getMessages(_): return .get
		case .getMessage(_, _): return .get
		case .createMessage(_): return .post
		case .deleteMessage(_, _): return .delete
		case .likeMessage(_, _): return .post
		case .unlikeMessage(_, _): return .delete
		}
	}
}

// MARK: - API Manager that supports async/await and error handling
class APIManager {
	static let shared = APIManager()
	
	private var cancellables = Set<AnyCancellable>()
	
	// System logger
	let logger = LogUtils.createLogger(tag: "APIManager")
	
	private init() {}
	
	/// Generic function to make API requests
	func request<T: Decodable>(
		endpoint: APIEndpoint,
		body: Encodable? = nil,
		queryParams: [String: Any]? = nil
	) async -> APIResult<T> {
		return await request(endpoint: endpoint, method: endpoint.method, body: body, queryParams: queryParams)
	}
	
	/// Generic function to make API requests
	func request<T: Decodable>(
		endpoint: APIEndpoint,
		method: HTTPMethod = .get,
		body: Encodable? = nil,
		queryParams: [String: Any]? = nil
	) async -> APIResult<T> {
		
		guard var urlComponents = URLComponents(string: "\(APICfg.baseURL)\(endpoint.path)") else {
			return .failure(APIError.invalidURL)
		}
		
		if let queryParams = queryParams {
			urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
		}
		
		guard let url = urlComponents.url else {
			return .failure(APIError.invalidURL)
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		// **Add Authorization Header if Token Exists**
		if let token = UserCfg.sessionToken() {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		
		if let body = body {
			do {
				request.httpBody = try JSONEncoder().encode(body)
			} catch {
				return .failure(.encodingFailed)
			}
		}
		
		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			
			// 🔹 Log Info
			self.logInfo(request, response, body: body, data: data)
			
			guard let httpResponse = response as? HTTPURLResponse else {
				return .failure(.invalidResponse)
			}
			
			guard (200...299).contains(httpResponse.statusCode) else {
				if let errorResponse = try? JSONDecoder().decode(APIErrorMessage.self, from: data) {
					return .failure(.apiError(errorResponse.error))
				}
				return .failure(.httpError(statusCode: httpResponse.statusCode))
			}
			
			guard !data.isEmpty else {
				return .failure(.noData)
			}
			
			do {
				let decodedData = try JSONDecoder().decode(T.self, from: data)
				return .success(decodedData)
			} catch let decodingError as DecodingError {
				return .failure(.decodingFailed(error: decodingError))
			}
			
		} catch {
			return .failure(.networkError(error.localizedDescription))
		}
	}
	
	// MARK: - Logging Functions
	
	private func logInfo(_ request: URLRequest, _ response: URLResponse, body: (any Encodable)?, data: Data) {
		var info = "🔹 API Request: \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "No URL")"
		
		if let headers = request.allHTTPHeaderFields {
			info += "\n🔹 Headers: \(headers)"
		}
		
		if let body = body, let jsonData = try? JSONEncoder().encode(body), let json = String(data: jsonData, encoding: .utf8) {
			info += "\n🔹 Body: \(json)"
		}
		
		if let httpResponse = response as? HTTPURLResponse {
			info += "\n🔹 Response Status Code: \(httpResponse.statusCode)"
			
			if let jsonString = String(data: data, encoding: .utf8) {
				info += "\n🔹 Response Body: \(jsonString)"
			}
		}
		
		self.logger.info("\(info)")
	}
}

// MARK: - API Error Response Struct
struct APIErrorMessage: Decodable {
	let error: String
}
