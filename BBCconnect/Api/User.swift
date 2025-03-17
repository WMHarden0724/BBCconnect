//
//  User.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine

public struct User: Codable {
	public let id: Int
	public let first_name: String
	public let last_name: String
	public let email: String
}

public struct UserSignUp: Codable {
	public let first_name: String
	public let last_name: String
	public let email: String
	public let password: String
}

public struct UserLogIn: Codable {
	public let email: String
	public let password: String
}

public struct UserAuthentication: Codable {
	public let user: User
	public let token: String
}

// MARK: - User API Calls
public extension User {
	// Fetch a user by ID
	static func getUser(id: Int, completion: @escaping (Result<User, APIError>) -> Void) {
		APIManager.shared.request(UserEndpoints.getUser(id), completion: completion)
	}

	// Create a new user
	static func createUser(_ user: UserSignUp, completion: @escaping (Result<UserAuthentication, APIError>) -> Void) {
		APIManager.shared.request(UserEndpoints.createUser, body: user, completion: completion)
	}
	
	// Login a new user
	static func loginUser(_ user: UserLogIn, completion: @escaping (Result<UserAuthentication, APIError>) -> Void) {
		APIManager.shared.request(UserEndpoints.login, body: user, completion: completion)
	}
}

// MARK: - User API Endpoints
public enum UserEndpoints: APIEndpoint {
	case getUser(Int)
	case createUser
	case login

	public var url: String {
		switch self {
		case .getUser(let id): return "https://api.example.com/users/\(id)"
		case .createUser: return "https://api.example.com/users"
		case .login: return "https://api.example.com/users"
		}
	}

	public var method: HTTPMethod {
		switch self {
		case .getUser: return .GET
		case .createUser: return .POST
		case .login: return .POST
		}
	}
}
