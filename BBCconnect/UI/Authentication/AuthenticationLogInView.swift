//
//  AuthenticationLogInView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import MessageUI
import AlertToast

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
		VStack(spacing: Dimens.verticalPadding) {
            Image("ChurchLogo")
                .resizable()
                .frame(width:250, height:250)
                .padding(.vertical, 30)
                .clipShape(.circle)
			
			Text("Log in to view stream")
				.foregroundColor(.primary)
				.font(.body)
				.multilineTextAlignment(.center)
			
			if case .failure(let error) = self.viewModel.loadingState {
				Text(error.localizedDescription)
					.font(.callout)
					.foregroundColor(.errorMain)
			}
			
			TextField("Email", text: self.$email)
				.foregroundColor(.primary)
				.textFieldStyle(PlainTextFieldStyle())
				.focused(self.$focusedField, equals: .email)
				.submitLabel(.next)
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
					self.focusedField = .password
				}
			
			SecureField("Password", text: self.$password)
				.textFieldStyle(PlainTextFieldStyle())
				.focused(self.$focusedField, equals: .password)
				.submitLabel(.done)
				.padding(.horizontal, 12)
				.padding(.vertical, 10)
				.foregroundColor(.primary)
				.overlay(
					Capsule()
						.stroke(Color.divider, lineWidth: 1)
				)
				.onSubmit {
					self.logIn()
				}
			
			BButton(style: .primary, text: "Log In", isLoading: self.viewModel.loadingState.isLoading) {
				self.logIn()
			}
			
			VStack(spacing: 0) {
				Text("Can't log in? Contact Video Booth at")
					.font(.body)
					.multilineTextAlignment(.center)
					.foregroundColor(.primaryMain)
				
				Button(action: {
					if MFMailComposeViewController.canSendMail() {
						self.showMailView.toggle()
					}
					else {
						self.showMailError.toggle()
					}
				}) {
					Text("Contact App Ministry")
						.font(.body)
						.foregroundColor(.blue)
				}
				.buttonStyle(.plain)
			}
			
			Spacer()
		}
		.sheet(isPresented: self.$showMailView) {
			MailView(
				recipient: "biblebaptistchurchconnect@gmail.com",
				subject: "Help from BBCConnect",
				body: ""
			)
		}
		.toast(isPresenting: self.$showMailError, alert: {
			AlertToast(type: .error(Color.errorMain), title: "Email not supported")
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
