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
	@Published var error: String?
	
	func fetchUser() async {
		self.loadingState = .loading
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .userProfile)
		
		DispatchQueue.main.async {
			self.loadingState = result
			if case .success(let userData) = result {
				self.user = userData
			}
			else if case .failure(let error) = result {
				self.error = error.localizedDescription
			}
		}
	}
}

@MainActor
class UserAvatarViewModel: ObservableObject {
	
	@Published var loadingState: APIResult<User> = .none
	@Published var error: String?
	
	func updateAvatar(avatarBase64: String) async {
		// TODO: THIS IS NOT DONE, SERVER WORK NEEDS TO BE FINISHED
		
		self.loadingState = .loading
//		let result: APIResult<User> = await APIManager.shared.request(endpoint: .userAvatar, body: UserUpdateAvatar(avatar: avatarBase64))
//		
//		DispatchQueue.main.async {
//			if case .success(let userData) = result {
//				UserCfg.setAvatar(avatar: userData.avatar)
//			}
//			else if case .failure(let error) = result {
//				self.error = error.localizedDescription
//			}
//			self.loadingState = result
//		}
		
		// For now just use the base64 passed in and update the cfg
		try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
		UserCfg.setAvatar(avatar: avatarBase64)
		self.loadingState = .success(User(id: 0, first_name: "", last_name: "", email: "", avatar: nil)) // mimic the result for now
	}
}
