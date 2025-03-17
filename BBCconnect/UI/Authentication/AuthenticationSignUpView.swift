//
//  AuthenticationSignUpView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct AuthenticationSignUpView: View {
	
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel = AuthenticationViewModel()
	
	@State private var viewSize: CGSize = .zero
	@State private var email = ""
	@State private var firstName = ""
	@State private var lastName = ""
	@State private var password = ""
	
	var body: some View {
		VStack(spacing: Dimens.vertical) {
			
			Text("Sign up for a BBC Connect account to ensure your data is up to date across your devices.")
				.foregroundColor(.textPrimary)
				.font(.body)
				.padding(.top, Dimens.vertical)
			
			if let error = self.viewModel.error {
				Text(error)
					.font(.callout)
					.foregroundColor(.errorMain)
			}
			
			TextField("Email", text: self.$email)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.autocapitalization(.none)
				.keyboardType(.emailAddress)
			
			TextField("First Name", text: self.$firstName)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.autocapitalization(.none)
				.keyboardType(.emailAddress)
			
			TextField("Last Name", text: self.$lastName)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.autocapitalization(.none)
				.keyboardType(.emailAddress)
			
			SecureField("Password", text: self.$password)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			BButton(style: .primary, text: "Sign Up", isLoading: self.viewModel.loadingState.isLoading) {
				self.signUp()
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
	
	private func signUp() {
		Task {
			await self.viewModel.createUser(email: self.email,
											firstName: self.firstName,
											lastName: self.lastName,
											password: self.password)
		}
	}
}
