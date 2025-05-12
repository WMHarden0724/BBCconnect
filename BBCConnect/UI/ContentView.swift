//
//  ContentView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct ContentView: View {
	
	@StateObject var manager = AppStateManager.shared
	
	var body: some View {
		Group {
			switch self.manager.currentState {
			case .main:
				MainTabsView()
			case .authLanding:
				AuthenticationLandingView()
			}
		}
		.animation(.easeInOut, value: self.manager.currentState)
	}
}

#Preview {
	ContentView()
}
