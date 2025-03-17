//
//  AuthenticationSignUpView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct AuthenticationSignUpView: View {
		
	@State private var viewSize: CGSize = .zero
	@State private var email = ""
	@State private var firstName = ""
	@State private var lastName = ""
	@State private var password = ""
	@State private var errorMessage = ""
	
	var body: some View {
		VStack(spacing: Dimens.vertical) {
			
			Text("Sign up for a BBC Connect account to ensure your data is up to date across your devices.")
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
			
			Button(action: {
				self.signUp()
			}) {
				Text("Sign Up")
					.font(.headline)
					.foregroundColor(.primaryContrast)
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.primaryMain)
					.cornerRadius(12)
					.shadow(radius: 4)
			}
			
			Spacer()
		}
		.readSize { size in
			self.viewSize = size
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea()
	}
	
	private func signUp() {
		if self.email.isEmpty || self.firstName.isEmpty || self.lastName.isEmpty || self.password.isEmpty {
			withAnimation {
				self.errorMessage = "Please check all required fields."
			}
			return
		}
		
		withAnimation {
			self.errorMessage = ""
		}
		
		// TODO
	}
}
