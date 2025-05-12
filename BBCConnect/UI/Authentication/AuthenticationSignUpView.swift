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
	
	@FocusState private var focusedField: Field?
	
	enum Field {
		case email, firstName, lastName, password, accessKey
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: Dimens.verticalPadding) {
				
				Image("ChurchLogo")
					.resizable()
					.frame(width: 175, height: 175)
					.padding(.vertical, 30)
					.clipShape(.circle)
				
				Text("Sign up for BBC stream")
					.foregroundColor(.primary)
					.font(.headline)
					.multilineTextAlignment(.center)
				
				if case .failure(let error) = self.viewModel.loadingState {
					Text(error.localizedDescription)
						.font(.callout)
						.foregroundColor(.errorMain)
				}
				
				BTextField("Email", text: self.$email)
					.keyboardType(.emailAddress)
					.textInputAutocapitalization(.never)
					.focused(self.$focusedField, equals: .email)
					.submitLabel(.next)
					.onSubmit {
						self.focusedField = .firstName
					}
				
				BTextField("First Name", text: self.$firstName)
					.textInputAutocapitalization(.words)
					.focused(self.$focusedField, equals: .firstName)
					.submitLabel(.next)
					.onSubmit {
						self.focusedField = .lastName
					}
				
				BTextField("Last Name", text: self.$lastName)
					.textInputAutocapitalization(.words)
					.focused(self.$focusedField, equals: .lastName)
					.submitLabel(.next)
					.onSubmit {
						self.focusedField = .password
					}
				
				BSecureField("Password", text: self.$password)
					.focused(self.$focusedField, equals: .password)
					.submitLabel(.next)
					.onSubmit {
						self.focusedField = .accessKey
					}
				
				if case .success(_) = self.viewModel.loadingState {
					Text("Account created. You will receive an email once an admin has approved.")
						.foregroundColor(.primaryMain)
						.frame(maxWidth: .infinity, alignment: .center)
				}
				else {
					BButton(style: .primary, text: "Sign Up", isLoading: self.viewModel.loadingState.isLoading) {
						self.signUp()
					}
				}
			}
		}
		.animation(.easeInOut, value: self.viewModel.loadingState)
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea(color: .background)
		.toolbarBackground(Color.clear, for: .navigationBar)
		.toolbarRole(.editor)
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
