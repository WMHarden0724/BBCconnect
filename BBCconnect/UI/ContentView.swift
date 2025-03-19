//
//  ContentView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct ContentView: View {
	
	var body: some View {
		TabView {
			HomeTabView()
				.tabItem {
					Label("Home", systemImage: "house")
				}
			
			LiveStreamTabView()
				.tabItem {
					Label("Stream", systemImage: "video")
				}
			
			ConversationsTabView()
				.tabItem {
					Label("Conversations", systemImage: "message.fill")
				}
		}
		.tint(.primaryMain)
		.checkAuthentication()
	}
}

#Preview {
	ContentView()
}
