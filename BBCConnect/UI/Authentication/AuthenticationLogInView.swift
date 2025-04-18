//
//  AuthenticationLogInView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import AlertToast
import MessageUI

struct AuthenticationLogInView: View {
	
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel = AuthenticationViewModel()
	
	@State private var viewSize: CGSize = .zero
	@State private var email = ""
	@State private var password = ""
	
	@State private var showMailView = false
	@State private var showMailError = false
	
	@FocusState private var focusedField: Field?
	
	enum Field {
		case email, password
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: Dimens.verticalPadding) {
				Image("ChurchLogo")
					.resizable()
					.frame(width: 175, height: 175)
					.padding(.vertical, 30)
					.clipShape(.circle)
				
				Text("Log in to view stream")
					.foregroundColor(.primary)
					.font(.headline)
					.multilineTextAlignment(.center)
				
				if case .failure(let error) = self.viewModel.loadingState {
					Text(error.localizedDescription)
						.font(.callout)
						.foregroundColor(.errorMain)
				}
				
				BTextField("Email", text: self.$email)
					.focused(self.$focusedField, equals: .email)
					.submitLabel(.next)
					.keyboardType(.emailAddress)
					.textContentType(.emailAddress)
					.textInputAutocapitalization(.never)
					.onSubmit {
						self.focusedField = .password
					}
				
				BSecureField("Password", text: self.$password)
					.focused(self.$focusedField, equals: .password)
					.submitLabel(.done)
					.onSubmit {
						self.logIn()
					}
				
				BButton(style: .primary, text: "Log In", isLoading: self.viewModel.loadingState.isLoading) {
					self.logIn()
				}
				
				NavigationLink(destination: AuthenticationForgotPasswordView(viewModel: self.viewModel)) {
					Text("Forgot Password?")
						.font(.system(size: 17, weight: .regular))
						.foregroundColor(.primary)
				}
				.buttonStyle(.plain)
			}
		}
		.sheet(isPresented: self.$showMailView) {
			MailView(
				recipient: "biblebaptistchurchconnect@gmail.com",
				subject: "Help from BBCConnectApp",
				body: ""
			)
		}
		.toast(isPresenting: self.$showMailError, duration: 5, offsetY: 60, alert: {
			AlertToast(displayMode: .hud, type: .error(Color.errorMain), title: "Email not supported")
		}, completion: {
			self.showMailError.toggle()
		})
		.animation(.easeInOut, value: self.viewModel.loadingState)
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea(color: .background)
		.toolbarBackground(Color.clear, for: .navigationBar)
		.toolbarRole(.editor)
	}
	
	private func logIn() {
		self.hideKeyboard()
		Task {
			await self.viewModel.loginUser(email: self.email, password: self.password)
		}
	}
}
