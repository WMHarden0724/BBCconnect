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
		VStack(spacing: Dimens.verticalPadding) {
			
			Text("Sign up for a BBC Connect account to ensure your data is up to date across your devices.")
				.foregroundColor(.primary)
				.font(.body)
				.padding(.top, Dimens.verticalPadding)
			
			if case .failure(let error) = self.viewModel.loadingState {
				Text(error.localizedDescription)
					.font(.callout)
					.foregroundColor(.errorMain)
			}
			
			TextField("Email", text: self.$email)
				.foregroundColor(.primary)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.keyboardType(.emailAddress)
				.textInputAutocapitalization(.never)
			
			TextField("First Name", text: self.$firstName)
				.foregroundColor(.primary)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.textInputAutocapitalization(.words)
			
			TextField("Last Name", text: self.$lastName)
				.foregroundColor(.primary)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.textInputAutocapitalization(.words)
			
			SecureField("Password", text: self.$password)
				.foregroundColor(.primary)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			BButton(style: .primary, text: "Sign Up", isLoading: self.viewModel.loadingState.isLoading) {
				self.signUp()
			}
			
			Spacer()
		}
		.animation(.easeInOut, value: self.viewModel.loadingState)
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea(color: .background)
	}
	
	private func signUp() {
		self.hideKeyboard()
		Task {
			await self.viewModel.createUser(email: self.email,
											firstName: self.firstName,
											lastName: self.lastName,
											password: self.password)
		}
	}
}
