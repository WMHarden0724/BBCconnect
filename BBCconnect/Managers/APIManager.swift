//
//  APIManager.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine

public class APIManager {
	public static let shared = APIManager()
	private init() {}

	// Store cancellables internally to prevent manual UI management
	private var cancellables = Set<AnyCancellable>()

	func request<T: Decodable>(
		_ endpoint: APIEndpoint,
		body: Encodable? = nil,
		completion: @escaping (Result<T, APIError>) -> Void
	) {
		guard let url = URL(string: endpoint.url) else {
			completion(.failure(.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue
		request.allHTTPHeaderFields = ["Content-Type": "application/json"]

		if let body = body {
			do {
				request.httpBody = try JSONEncoder().encode(body)
			} catch {
				completion(.failure(.encodingFailed))
				return
			}
		}

		// Perform API Call and store in cancellables
		URLSession.shared.dataTaskPublisher(for: request)
			.tryMap { result -> Data in
				guard let response = result.response as? HTTPURLResponse else {
					throw APIError.invalidResponse
				}

				if !(200...299).contains(response.statusCode) {
					if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: result.data) {
						throw APIError.apiError(apiError.message)
					} else {
						throw APIError.httpError(statusCode: response.statusCode)
					}
				}

				return result.data
			}
			.decode(type: T.self, decoder: JSONDecoder())
			.mapError { error in
				if let apiError = error as? APIError {
					return apiError
				} else if let decodingError = error as? DecodingError {
					return APIError.decodingFailed(error: decodingError)
				} else {
					return APIError.networkError(error.localizedDescription)
				}
			}
			.sink(receiveCompletion: { completionResult in
				switch completionResult {
				case .failure(let error):
					completion(.failure(error))
				case .finished:
					break
				}
			}, receiveValue: { decodedData in
				completion(.success(decodedData))
			})
			.store(in: &cancellables)
	}
}

// MARK: - API Endpoint Protocol
public protocol APIEndpoint {
	var url: String { get }
	var method: HTTPMethod { get }
}

// MARK: - HTTP Methods Enum
public enum HTTPMethod: String {
	case GET, POST, PUT, DELETE
}

// MARK: - API Error Handling
public enum APIError: Error, LocalizedError {
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
}

// MARK: - API Error Response Struct
public struct APIErrorResponse: Decodable {
	let message: String
}
