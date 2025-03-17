//
//  Authentication.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI


struct CheckAuthentication: ViewModifier {
	
	@StateObject private var viewModel = UserViewModel()
	
	@State private var showAuth = false
	
	func body(content: Content) -> some View {
		content
			.onAppear {
				if !UserCfg.isLoggedIn() {
					self.showAuth.toggle()
				}
				else {
					Task {
						// Always gets the latest user info
						await self.viewModel.fetchUser()
					}
				}
			}
			.onCfgChanged(onChanged: { cfgType, _ in
				if cfgType == .sessionToken {
					if !UserCfg.isLoggedIn() {
						self.showAuth.toggle()
					}
				}
			})
			.fullScreenCover(isPresented: self.$showAuth) {
				AuthenticationLanding()
					.interactiveDismissDisabled()
					.onCfgChanged(onChanged: { cfgType, _ in
						if cfgType == .sessionToken {
							if UserCfg.isLoggedIn() {
								self.showAuth.toggle()
							}
						}
					})
			}
	}
}

public extension View {
	func checkAuthentication() -> some View {
		modifier(CheckAuthentication())
	}
}
