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
			
			ConversationsTabView()
				.tabItem {
					Label("Messages", systemImage: "message.fill")
				}
			
			LiveStreamTabView()
				.tabItem {
					Label("Live Stream", systemImage: "videoprojector.fill")
				}
			
			OnDemandTabView()
				.tabItem {
					Label("On-Demand", systemImage: "video")
				}
			
			MembersTabView()
				.tabItem {
					Label("Members", systemImage: "person.2.fill")
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
