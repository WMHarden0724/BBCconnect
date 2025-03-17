//
//  Authentication.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI


struct CheckAuthentication: ViewModifier {
	
	@State private var showAuth = false
	
	func body(content: Content) -> some View {
		content
			.onAppear {
				if !UserCfg.isLoggedIn() {
					self.showAuth.toggle()
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
				AuthenticationLanding().interactiveDismissDisabled()
			}
	}
}

public extension View {
	func checkAuthentication() -> some View {
		modifier(CheckAuthentication())
	}
}
