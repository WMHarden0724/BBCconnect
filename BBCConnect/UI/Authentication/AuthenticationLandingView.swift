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
            VStack(spacing: Dimens.verticalPadding) {
				Spacer()
				
				Image("Landing")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.cornerRadius(8)
					.padding(.horizontal, Dimens.horizontalPadding)
					.padding(.bottom, 80)
                
                Spacer()

                BNavigationLink(
                    style: .primary, value: NavigationDestination.signUp,
                    text: "Sign Up")

                BNavigationLink(
                    style: .secondary, value: NavigationDestination.logIn,
                    text: "Log In")
            }
            .applyHorizontalPadding(viewWidth: self.viewSize.width)
			.backgroundIgnoreSafeArea(color: .background)
            .padding(.bottom, Dimens.verticalPadding)
            .navigationDestination(for: NavigationDestination.self) { dest in
                if dest == .signUp {
                    AuthenticationSignUpView()
                } else if dest == .logIn {
                    AuthenticationLogInView()
                }
            }
            .readSize { size in
                self.viewSize = size
            }
        }
        .tint(.primaryMain)
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationLanding()
    }
}
