//
//  User.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation

public struct User: Codable, Equatable {
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
