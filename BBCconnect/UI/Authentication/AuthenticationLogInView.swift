//
//  AuthenticationLogInView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct AuthenticationLogInView: View {
	
	@State private var viewSize: CGSize = .zero
	@State private var email = ""
	@State private var password = ""
	@State private var errorMessage = ""
	
	@State private var isShowingEmailView = false
	@State private var isLoading = false
	
	var body: some View {
		VStack(spacing: Dimens.vertical) {
			
			Text("Log into your BBC Connect account to store your data and keep them updated across all your devices.")
				.foregroundColor(.textPrimary)
				.font(.body)
				.padding(.top, Dimens.vertical)
			
			if !errorMessage.isEmpty {
				Text(self.errorMessage)
					.font(.caption)
					.foregroundColor(.errorMain)
			}
			
			TextField("Email", text: self.$email)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.autocapitalization(.none)
				.keyboardType(.emailAddress)
			
			SecureField("Password", text: self.$password)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			BButton(style: .primary, text: "Log In") {
				self.logIn()
			}
			
			VStack(spacing: 0) {
				Text("Can't log in? Contact Video Booth at")
					.font(.body)
					.foregroundColor(.primaryMain)
				
				Button(action: {
					
				}) {
					Text("biblebaptistchurchconnect@gmail.com")
						.font(.body)
						.foregroundColor(.blue)
				}
				.sheet(isPresented: self.$isShowingEmailView) {
					EmailView(isPresented: self.$isShowingEmailView, recipient: "biblebaptistchurchconnect@gmail.com", subject: "Log in issues", body: "")
				}
			}
			
			Spacer()
		}
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea()
	}
	
	private func logIn() {
		if self.email.isEmpty || self.password.isEmpty {
			withAnimation {
				self.errorMessage = "Invalid email and password."
			}
			return
		}
		
		withAnimation {
			self.errorMessage = ""
			self.isLoading = true
		}
		
		User.loginUser(UserLogIn(email: self.email,
								 password: self.password)) { result in
			switch result {
			case .success(let auth):
				UserCfg.logIn(result: auth)
			case .failure(let error):
				withAnimation {
					self.errorMessage = error.localizedDescription
					self.isLoading = false
				}
			}
		}
	}
}
