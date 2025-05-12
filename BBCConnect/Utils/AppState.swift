//
//  AppState.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/12/25.
//

import Combine

enum AppState {
	case authLanding
	case main
}

class AppStateManager: ObservableObject {
	
	public static let shared = AppStateManager()
	
	@Published var currentState: AppState = .main
	
	private init() {
		if UserCfg.isLoggedIn() {
			self.currentState = .main
		}
	}
	
	func navigateToAuth() {
		self.currentState = .authLanding
	}
	
	func navigateToMain() {
		self.currentState = .main
	}
}
