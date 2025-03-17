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
				
				VStack(spacing: Dimens.verticalPadding) {
					Spacer()
					
					BNavigationLink(style: .primary, value: NavigationDestination.signUp, text: "Sign Up")
					
					BNavigationLink(style: .secondary, value: NavigationDestination.logIn, text: "Log In")
				}
				.applyHorizontalPadding(viewWidth: self.viewSize.width)
				.padding(.bottom, Dimens.verticalPadding)
				.navigationDestination(for: NavigationDestination.self) { dest in
					if dest == .signUp {
						AuthenticationSignUpView()
					}
					else if dest == .logIn {
						AuthenticationLogInView()
					}
				}
			}
			.backgroundIgnoreSafeArea()
		}
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
