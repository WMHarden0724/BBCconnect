//
//  AuthenticationViewModel.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
	
	@Published var user: User?
	@Published var loadingState: APIResult<User> = .none
	@Published var error: String?
	
	func createUser(email: String, firstName: String, lastName: String, password: String) async {
		guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
			self.error = "Please check all required fields."
			return
		}
		
		self.loadingState = .loading
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .createUser)
		
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
	
	func loginUser(email: String, password: String) async {
		guard !email.isEmpty, !password.isEmpty else {
			self.error = "Invalid email or password."
			return
		}
		
		self.loadingState = .loading
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .login)
		
		try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
		
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
