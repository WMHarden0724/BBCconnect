//
//  BBCconnectApp.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

@main
struct BBCconnectApp: App {
	
	init() {
		Theme.apply()
		
		// Ensure we init the pub sub manager
		_ = PubSubManager.shared
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
