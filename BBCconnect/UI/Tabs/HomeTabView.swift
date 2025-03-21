//
//  HomeTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct HomeTabView : View {
	
	@State private var avatarId = Date()
	
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
			.backgroundIgnoreSafeArea(color: .background)
			.onCfgChanged(onChanged: { cfgType, _ in
				if cfgType == .avatar {
					self.avatarId = Date()
				}
			})
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(Color.clear, for: .navigationBar)
			.toolbarRole(.editor)
			.navigationTitle(Date.now.formatted(.dateTime.month().day().year()))
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: UserProfileView()) {
						Avatar(type: .userCfg, size: .xxs, state: .normal)
							.id(self.avatarId)
					}
				}
			}
		}
		.tint(.blue)
	}
}
