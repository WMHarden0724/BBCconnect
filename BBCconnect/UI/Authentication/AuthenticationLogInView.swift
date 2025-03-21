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
				.foregroundColor(.primary)
				.font(.body)
				.multilineTextAlignment(.center)
				.padding(.top, Dimens.verticalPadding)
			
			if case .failure(let error) = self.viewModel.loadingState {
				Text(error.localizedDescription)
					.font(.callout)
					.foregroundColor(.errorMain)
			}
			
			TextField("Email", text: self.$email)
				.foregroundColor(.primary)
				.textFieldStyle(PlainTextFieldStyle())
				.keyboardType(.emailAddress)
				.textInputAutocapitalization(.never)
				.padding(.horizontal, 12)
				.padding(.vertical, 10)
				.foregroundColor(.primary)
				.overlay(
					Capsule()
						.stroke(Color.divider, lineWidth: 1)
				)
			
			SecureField("Password", text: self.$password)
				.textFieldStyle(PlainTextFieldStyle())
				.padding(.horizontal, 12)
				.padding(.vertical, 10)
				.foregroundColor(.primary)
				.overlay(
					Capsule()
						.stroke(Color.divider, lineWidth: 1)
				)
			
			BButton(style: .primary, text: "Log In", isLoading: self.viewModel.loadingState.isLoading) {
				self.logIn()
			}
			
			VStack(spacing: 0) {
				Text("Can't log in? Contact Video Booth at")
					.font(.body)
					.multilineTextAlignment(.center)
					.foregroundColor(.primaryMain)
				
				Text("biblebaptistchurchconnect@gmail.com")
					.font(.body)
					.foregroundColor(.blue)
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
	
	private func logIn() {
		self.hideKeyboard()
		Task {
			await self.viewModel.loginUser(email: self.email, password: self.password)
		}
	}
}
