//
//  AuthenticationForgotPasswordView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/21/25.
//

import SwiftUI
import AlertToast

struct AuthenticationForgotPasswordView: View {
	
	@Environment(\.dismiss) var dismiss
	@ObservedObject var viewModel: AuthenticationViewModel
	
	@State private var viewSize: CGSize = .zero
	@State private var email = ""
	
	@State private var showSuccessMessage = false
	@State private var errorMessage: String?
	
	@FocusState private var focusedField: Field?
	
	enum Field {
		case email
	}
	
	var body: some View {
		VStack(spacing: Dimens.verticalPadding) {
			Text("Reset your password")
				.foregroundColor(.primary)
				.font(.headline)
				.multilineTextAlignment(.center)
				.padding(.top, Dimens.verticalPadding)
			
			if let errorMessage = self.errorMessage {
				Text(errorMessage)
					.font(.callout)
					.foregroundColor(.errorMain)
			}
			else if self.showSuccessMessage {
				Text("Reset instructions sent")
					.font(.callout)
					.foregroundColor(.blue)
			}
			
			TextField("Email", text: self.$email)
				.foregroundColor(.primary)
				.textFieldStyle(PlainTextFieldStyle())
				.focused(self.$focusedField, equals: .email)
				.submitLabel(.done)
				.keyboardType(.emailAddress)
				.textInputAutocapitalization(.never)
				.padding(.horizontal, 12)
				.padding(.vertical, 10)
				.foregroundColor(.primary)
				.overlay(
					Capsule()
						.stroke(Color.divider, lineWidth: 1)
				)
				.onSubmit {
					self.resetPassword()
				}
			
			BButton(style: .primary, text: "Reset Password", isLoading: self.viewModel.loadingState.isLoading) {
				self.resetPassword()
			}
			
			Spacer()
		}
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea(color: .background)
		.toolbarBackground(Color.clear, for: .navigationBar)
		.toolbarRole(.editor)
	}
	
	private func resetPassword() {
		self.hideKeyboard()
		Task {
			let result = await self.viewModel.resetPassword(email: self.email)
			DispatchQueue.main.async {
				withAnimation {
					if result.0 {
						self.showSuccessMessage = true
					}
					else if let error = result.1 {
						self.errorMessage = error
					}
				}
			}
		}
	}
}
