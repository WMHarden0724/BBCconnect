//
//  AuthenticationLogInView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct AuthenticationLogInView: View {
	
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel = AuthenticationViewModel()
	
	@State private var viewSize: CGSize = .zero
	@State private var email = ""
	@State private var password = ""
	
	var body: some View {
		VStack(spacing: Dimens.verticalPadding) {
			
			Text("Log into your BBC Connect account to store your data and keep them updated across all your devices.")
				.foregroundColor(.textPrimary)
				.font(.body)
				.padding(.top, Dimens.verticalPadding)
			
			if let error = self.viewModel.error {
				Text(error)
					.font(.callout)
					.foregroundColor(.errorMain)
			}
			
			TextField("Email", text: self.$email)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.autocapitalization(.none)
				.keyboardType(.emailAddress)
			
			SecureField("Password", text: self.$password)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			BButton(style: .primary, text: "Log In", isLoading: self.viewModel.loadingState.isLoading) {
				self.logIn()
			}
			
			VStack(spacing: 0) {
				Text("Can't log in? Contact Video Booth at")
					.font(.body)
					.foregroundColor(.primaryMain)
				
				Text("biblebaptistchurchconnect@gmail.com")
					.font(.body)
					.foregroundColor(.blue)
			}
			
			Spacer()
		}
		.animation(.easeInOut, value: self.viewModel.error)
		.animation(.easeInOut, value: self.viewModel.loadingState)
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea()
	}
	
	private func logIn() {
		Task {
			await self.viewModel.loginUser(email: self.email, password: self.password)
		}
	}
}
