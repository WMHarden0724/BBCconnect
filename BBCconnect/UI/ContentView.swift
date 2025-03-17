//
//  ContentView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct ContentView: View {
	
	var body: some View {
		NavigationStack {
			VStack {
				Spacer()
				Image(systemName: "globe")
					.imageScale(.large)
					.foregroundStyle(.tint)
				Text("Hello, world!")
					.frame(maxWidth: .infinity)
				Spacer()
			}
			.padding()
			.backgroundIgnoreSafeArea()
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle(Date.now.formatted(.dateTime.month().day().year()))
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: UserProfileView()) {
						AvatarImageView(style: .small)
					}
				}
			}
		}
		.checkAuthentication()
	}
}

#Preview {
	ContentView()
}
