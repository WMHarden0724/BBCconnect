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
	
	@Published var loadingState: APIResult<UserAuthentication> = .none
	@Published var error: String?
	
	func createUser(email: String, firstName: String, lastName: String, password: String) async {
		guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
			self.error = "Please check all required fields."
			return
		}
		
		self.loadingState = .loading
		let result: APIResult<UserAuthentication> = await APIManager.shared.request(endpoint: .createUser,
																					body: UserSignUp(first_name: firstName,
																									 last_name: lastName,
																									 email: email,
																									 password: password))
		
		DispatchQueue.main.async {
			if case .success(let data) = result {
				UserCfg.logIn(result: data)
			}
			else if case .failure(let error) = result {
				self.error = error.localizedDescription
			}
			self.loadingState = result
		}
	}
	
	func loginUser(email: String, password: String) async {
		guard !email.isEmpty, !password.isEmpty else {
			self.error = "Invalid email or password."
			return
		}
		
		self.loadingState = .loading
		let result: APIResult<UserAuthentication> = await APIManager.shared.request(endpoint: .login,
																					body: UserLogIn(email: email,
																									password: password))
				
		DispatchQueue.main.async {
			if case .success(let data) = result {
				UserCfg.logIn(result: data)
			}
			else if case .failure(let error) = result {
				self.error = error.localizedDescription
			}
			self.loadingState = result
		}
	}
}
