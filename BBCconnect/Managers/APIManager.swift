//
//  APIManager.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine

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
		case .apiError(let message): return "API Error: \(message)"
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

enum APIEndpoint {
	case createUser
	case login
	case userProfile
	
	var path: String {
		switch self {
		case .createUser: return "/user/create"
		case .login: return "/user/login"
		case .userProfile: return "/user/profile"
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .createUser: return .post
		case .login: return .post
		case .userProfile: return .get
		}
	}
}

// MARK: - API Manager that supports async/await and error handling
class APIManager {
	static let shared = APIManager()
	
	private let baseURL = URL(string: "https://your-api.com")!
	private var cancellables = Set<AnyCancellable>()
	
	private init() {}
	
	/// Generic function to make API requests
	func request<T: Decodable>(
		endpoint: APIEndpoint,
		body: Encodable? = nil
	) async -> APIResult<T> {
		return await request(endpoint: endpoint, method: endpoint.method, body: body)
	}
	
	/// Generic function to make API requests
	func request<T: Decodable>(
		endpoint: APIEndpoint,
		method: HTTPMethod = .get,
		body: Encodable? = nil
	) async -> APIResult<T> {
		
		guard let url = URL(string: endpoint.path, relativeTo: self.baseURL) else {
			return .failure(.invalidURL)
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		if let body = body {
			do {
				request.httpBody = try JSONEncoder().encode(body)
			} catch {
				return .failure(.encodingFailed)
			}
		}
		
		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			guard let httpResponse = response as? HTTPURLResponse else {
				return .failure(.invalidResponse)
			}
			
			guard (200...299).contains(httpResponse.statusCode) else {
				if let errorResponse = try? JSONDecoder().decode(APIErrorMessage.self, from: data) {
					return .failure(.apiError(errorResponse.message))
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
}

// MARK: - API Error Response Struct
struct APIErrorMessage: Decodable {
	let message: String
}
