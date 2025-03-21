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
	
	func updateAvatar(data: Data) async {
		// TODO: THIS IS NOT DONE, SERVER WORK NEEDS TO BE FINISHED
		
//		let result: APIResult<User> = await APIManager.shared.request(endpoint: .userAvatar, body: UserUpdateAvatar(avatar: "data:image/png;base64,\(avatarBase64)"))
//
//		DispatchQueue.main.async {
//			if case .success(let data) = result {
//				UserCfg.setAvatar(avatar: userData.avatar)
//			}
//
//			self.loadingState = result
//		}
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
