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
	
	func createUser(email: String, firstName: String, lastName: String, password: String) async {
		guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
			self.loadingState = .failure(.apiError("Please check all required fields."))
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
			
			self.loadingState = result
		}
	}
	
	func loginUser(email: String, password: String) async {
		guard !email.isEmpty, !password.isEmpty else {
			self.loadingState = .failure(.apiError("Invalid email or password."))
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
			
			self.loadingState = result
		}
	}
	
	func resetPassword(email: String) async -> (Bool, String?) {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .forgotPassword, body: ForgotPasswordPayload(email: email))
		
		if case .success(_) = result {
			return (true, nil)
		}
		else if case .failure(let error) = result {
			return (false, error.localizedDescription)
		}
		
		return (false, nil)
	}
}

fileprivate struct ForgotPasswordPayload: Codable {
	let email: String
}
