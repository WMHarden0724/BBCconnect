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
		}
		.tint(.primaryMain)
		.checkAuthentication()
	}
}

#Preview {
	ContentView()
}
