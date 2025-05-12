//
//  MainTabsView.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/12/25.
//

import SwiftUI

struct MainTabsView: View {
	
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
	}
}

#Preview {
	ContentView()
}
