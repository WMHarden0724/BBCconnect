//
//  Landing.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import SwiftUI

enum NavigationDestination: Hashable {
	case signUp
	case logIn
}

struct AuthenticationLanding: View {
	
	@State private var navigationDestination: NavigationDestination? = nil
	@State private var viewSize: CGSize = .zero
	@State private var isShowingLogIn = false
	@State private var isShowingSignUp = false
	
	var body: some View {
		NavigationStack {
			ZStack {
				
				// TODO add your background image here
				
				VStack(spacing: Dimens.vertical) {
					Spacer()
					
					NavigationLink(value: NavigationDestination.signUp) {
						Text("Sign Up")
							.font(.headline)
							.foregroundColor(.primaryContrast)
							.padding()
							.frame(maxWidth: .infinity)
							.background(Color.primaryMain)
							.cornerRadius(12)
							.shadow(radius: 4)
					}
					
					NavigationLink(value: NavigationDestination.logIn) {
						Text("Log In")
							.font(.headline)
							.foregroundColor(.secondaryContrast)
							.padding()
							.frame(maxWidth: .infinity)
							.background(Color.secondaryMain)
							.cornerRadius(12)
							.shadow(radius: 4)
					}
				}
				.applyHorizontalPadding(viewWidth: self.viewSize.width)
				.padding(.bottom, Dimens.vertical)
				.navigationDestination(for: NavigationDestination.self) { dest in
					if dest == .signUp {
						AuthenticationSignUpView()
					}
					else if dest == .logIn {
						AuthenticationLogInView()
					}
				}
			}
		}
		.backgroundIgnoreSafeArea(color: Color.backgroundDark)
		.readSize { size in
			self.viewSize = size
		}
	}
}

struct LandingView_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticationLanding()
	}
}
