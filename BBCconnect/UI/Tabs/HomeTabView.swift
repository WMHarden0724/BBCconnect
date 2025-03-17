//
//  HomeTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct HomeTabView : View {
	
	var body: some View {
		NavigationStack {
			VStack(spacing: Dimens.verticalPadding) {
				Spacer()
				Image(systemName: "house")
					.imageScale(.large)
					.foregroundStyle(.tint)
				Text("Home stuff here")
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
	}
}
