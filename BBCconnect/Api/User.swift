//
//  User.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation

public struct User: Codable, Equatable, Hashable, Identifiable {
	public let id: Int
	public let first_name: String
	public let last_name: String
	public let email: String
	public let avatar: String?
}

public struct UserSignUp: Codable, Equatable {
	public let first_name: String
	public let last_name: String
	public let email: String
	public let password: String
}

public struct UserLogIn: Codable, Equatable {
	public let email: String
	public let password: String
}

public struct UserAuthentication: Codable, Equatable {
	public let user: User
	public let token: String
}

public struct UserUpdateAvatar: Codable, Equatable {
	public let avatar: String
}

extension User {
	func fullName() -> String {
		return "\(self.first_name) \(self.last_name)"
	}
	
	func initials() -> String {
		return "\(self.first_name.first!)\(self.last_name.first!)"
	}
}

extension User {

	static let sampleUser1 = User(id: 1,
								  first_name: "Garrett",
								  last_name: "Franks",
								  email: "lgfz71@gmail.com",
								  avatar: nil)
	
	static let sampleUser2 = User(id: 2,
								  first_name: "Wesley",
								  last_name: "Harden",
								  email: "test@gmail.com",
								  avatar: nil)
	
	static let sampleUser3 = User(id: 3,
								  first_name: "Test",
								  last_name: "User",
								  email: "test@test.com",
								  avatar: nil)
	
	static let sampleUser4 = User(id: 4,
								  first_name: "Test",
								  last_name: "User",
								  email: "test@test.com",
								  avatar: nil)
	
	static let sampleUser5 = User(id: 5,
								  first_name: "Test",
								  last_name: "User",
								  email: "test@test.com",
								  avatar: nil)
	
	static let sampleUser6 = User(id: 6,
								  first_name: "Test",
								  last_name: "User",
								  email: "test@test.com",
								  avatar: nil)
	
	static let sampleUser7 = User(id: 7,
								  first_name: "Test",
								  last_name: "User",
								  email: "test@test.com",
								  avatar: nil)
	
	static let sampleUser8 = User(id: 8,
								  first_name: "Test",
								  last_name: "User",
								  email: "test@test.com",
								  avatar: nil)
}
