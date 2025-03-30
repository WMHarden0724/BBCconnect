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
			BulletinTabView()
				.tabItem {
					Label("Bulletin", systemImage: "newspaper")
				}
			
			LiveStreamTabView()
				.tabItem {
					Label("Stream", systemImage: "video")
				}
			
			ConversationsTabView()
				.tabItem {
					Label("Messages", systemImage: "message.fill")
				}
		}
		.tint(.primaryMain)
		.toolbarBackground(.hidden, for: .tabBar)
		.checkAuthentication()
	}
}

#Preview {
	ContentView()
}
