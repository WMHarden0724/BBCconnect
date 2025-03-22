//
//  UserViewModel.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
	
	@Published var user: User?
	@Published var loadingState: APIResult<User> = .none
	
	func fetchUser() async {
		self.loadingState = .loading
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .userProfile)
		
		DispatchQueue.main.async {
			if case .success(let userData) = result {
				self.user = userData
			}
			
			self.loadingState = result
		}
	}
	
	func updateUserProfile(email: String? = nil, firstName: String? = nil, lastName: String? = nil, avatar: Data? = nil) async -> (User?, String?) {
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .updateUserProfile, body: UpdateUserProfilePayload(email: email,
																																   first_name: firstName,
																																   last_name: lastName,
																																   avatar: avatar))
		
		if case .success(let data) = result {
			UserCfg.updateUser(user: data)
			return (data, nil)
		}
		else if case .failure(let error) = result {
			return (nil, error.localizedDescription)
		}
		
		return (nil, nil)
	}
}

@MainActor
open class UserSearchViewModel: ObservableObject {
	
	@Published var users = [User]()
	
	func searchUsers(query: String) async {
		let queryParams = ["q": query]
		let result: APIResult<[User]> = await APIManager.shared.request(endpoint: .searchUsers, queryParams: queryParams)
		
		DispatchQueue.main.async {
			if case .success(let data) = result {
				self.users = data.filter { $0.id != UserCfg.userId() }
			}
		}
	}
}

fileprivate struct UpdateUserProfilePayload: Codable {
	let email: String?
	let first_name: String?
	let last_name: String?
	let avatar: String?
	
	init(email: String? = nil, first_name: String? = nil, last_name: String? = nil, avatar: Data? = nil) {
		self.email = email
		self.first_name = first_name
		self.last_name = last_name
		
		if let avatar = avatar {
			self.avatar = "data:image/png;base64,\(avatar.base64EncodedString())"
		}
		else {
			self.avatar = nil
		}
	}
}
