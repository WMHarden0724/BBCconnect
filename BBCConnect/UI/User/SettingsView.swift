//
//  SettingsView.swift
//  BBCConnect
//
//  Created by Garrett Franks on 4/18/25.
//

import SwiftUI

struct SettingsView : View {
	
	@State private var showLogoutAlert = false
	
	@ViewBuilder
	private func userProfileView() -> some View {
		ZStack {
			CardView {
				HStack(alignment: .center, spacing: Dimens.horizontalPadding) {
					
					Avatar(type: .userCfg, size: .sm, state: .normal)
					
					VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
						Text("\(UserCfg.firstName() ?? "") \(UserCfg.lastName() ?? "")")
							.font(.system(size: 17, weight: .medium))
							.foregroundColor(.primary)
							.lineLimit(1)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						Text(UserCfg.email() ?? "")
							.font(.subheadline)
							.foregroundColor(.secondary)
							.lineLimit(2)
							.truncationMode(.tail)
							.multilineTextAlignment(.leading)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					
					Image(systemName: "chevron.right")
						.imageScale(.medium)
						.foregroundColor(.actionActive)
				}
				.padding(.horizontal, Dimens.horizontalPadding)
				.padding(.vertical, Dimens.verticalPadding)
			}
			
			NavigationLink(destination: UserProfileView()) {
				EmptyView()
			}.opacity(0)
		}
	}
	
	var body: some View {
		List {
			self.userProfileView()
				.padding(.horizontal, Dimens.horizontalPadding)
				.padding(.top, Dimens.verticalPadding)
				.buttonStyle(.plain)
				.listRowSeparator(.hidden)
				.listRowBackground(Color.clear)
				.listRowSpacing(0)
				.listRowInsets(EdgeInsets())
			
			CardView {
				VStack(spacing: 0) {
					WebLinkButton(title: "Service Times",
								  url: URL(string: "http://ec2-3-16-206-208.us-east-2.compute.amazonaws.com/about")!,
								  includeDivider: true)
					
					WebLinkButton(title: "Sunday School",
								  url: URL(string: "http://ec2-3-16-206-208.us-east-2.compute.amazonaws.com/sunday-school")!,
								  includeDivider: true)
					
					WebLinkButton(title: "Bible Baptist Institute",
								  url: URL(string: "http://ec2-3-16-206-208.us-east-2.compute.amazonaws.com/bbi")!,
								  includeDivider: true)
					
					WebLinkButton(title: "Deaf Ministry",
								  url: URL(string: "http://ec2-3-16-206-208.us-east-2.compute.amazonaws.com/deaf-ministry")!,
								  includeDivider: true)
					
					WebLinkButton(title: "Missionary Support App.",
								  url: URL(string: "http://ec2-3-16-206-208.us-east-2.compute.amazonaws.com/missionary-support-app")!,
								  includeDivider: false)
				}
			}
			.padding(.horizontal, Dimens.horizontalPadding)
			.padding(.top, Dimens.verticalPadding)
			.buttonStyle(.plain)
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
			.listRowSpacing(0)
			.listRowInsets(EdgeInsets())
			
			BButton(style: .destructive, text: "Log Out") {
				self.showLogoutAlert.toggle()
			}
				.padding(.horizontal, Dimens.horizontalPadding)
				.padding(.top, Dimens.verticalPadding)
				.buttonStyle(.plain)
				.listRowSeparator(.hidden)
				.listRowBackground(Color.clear)
				.listRowSpacing(0)
				.listRowInsets(EdgeInsets())
		}
		.listStyle(.plain)
		.scrollContentBackground(.hidden)
		.backgroundIgnoreSafeArea(color: .background)
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
		.toolbarRole(.editor)
		.navigationTitle("Settings")
		.alert("Log Out", isPresented: self.$showLogoutAlert) {
			Button("Cancel", role: .cancel) { }
			Button("Log Out", role: .destructive) {
				UserCfg.logOut()
			}
		} message: {
			Text("Are you sure you want to log out?")
		}
	}
}

struct WebLinkButton: View {
	
	@State private var showSheet = false
	let title: String
	let url: URL
	let includeDivider: Bool
	
	var body: some View {
		Button(action: {
			self.showSheet.toggle()
		}) {
			VStack(spacing: 0) {
				HStack {
					Text(self.title)
						.foregroundColor(.primary)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Image(systemName: "chevron.right")
						.imageScale(.medium)
						.foregroundColor(.actionActive)
				}
				.padding(.horizontal, Dimens.horizontalPadding)
				.padding(.vertical, Dimens.verticalPadding)
				
				if self.includeDivider {
					Divider().foregroundColor(.divider)
				}
			}
		}
		.buttonStyle(.plain)
		.sheet(isPresented: self.$showSheet) {
			SafariView(url: self.url)
		}
	}
}
