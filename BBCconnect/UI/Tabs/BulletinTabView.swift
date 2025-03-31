//
//  BulletinTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import AlertToast

struct BulletinTabView : View {
	
	@StateObject private var viewModel = BulletinsViewModel()
	
	@State private var showNewBulletinsAvailable = false
	@State private var avatarId = Date()
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(self.viewModel.bulletins, id: \.id) { bulletin in
					BulletinListItem(bulletin: bulletin)
						.padding(.leading, Dimens.horizontalPadding)
						.padding(.trailing, Dimens.horizontalPadding)
						.padding(.top, self.viewModel.bulletins.firstIndex(where: { $0.id == bulletin.id }) == 0 ? Dimens.verticalPaddingLg : 0)
						.padding(.bottom, Dimens.verticalPaddingXl)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
				}
				
				if self.viewModel.isLoading {
					HStack {
						Spacer()
						
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
						
						Spacer()
					}
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
				}
				else if self.viewModel.isError {
					Text("Failed to load bulletins")
						.font(.headline)
						.foregroundColor(.primary)
						.padding(.vertical, Dimens.verticalPadding)
						.padding(.horizontal, Dimens.horizontalPadding)
						.frame(maxWidth: .infinity)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
				}
				else if self.viewModel.bulletins.isEmpty {
					Text(!self.viewModel.searchQuery.isEmpty ? "No bulletins match your search criteria" : "No bulletins")
						.font(.headline)
						.foregroundColor(.primary)
						.padding(.vertical, Dimens.verticalPadding)
						.padding(.horizontal, Dimens.horizontalPadding)
						.frame(maxWidth: .infinity)
						.listRowSeparator(.hidden)
						.listRowBackground(Color.clear)
						.listRowSpacing(0)
						.listRowInsets(EdgeInsets())
				}
				else if self.viewModel.canLoadMore {
					Button(action: {
						self.viewModel.fetchBulletins(query: self.viewModel.searchQuery)
					}) {
						Text("Load More")
							.font(.headline)
							.foregroundColor(.primary)
							.frame(maxWidth: .infinity)
							.padding(.vertical, Dimens.verticalPadding)
							.padding(.horizontal, Dimens.horizontalPadding)
					}
					.buttonStyle(.plain)
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
				}
			}
			.listStyle(.plain)
			.refreshable {
				self.viewModel.fetchBulletins(reset: true, query: self.viewModel.searchQuery)
			}
			.searchable(text: self.$viewModel.searchQuery,
						prompt: "Search bulletins")
			.toast(isPresenting: self.$viewModel.newBulletinsAvailable, duration: 5, offsetY: 60, alert: {
				AlertToast(displayMode: .hud, type: .complete(Color.blue), title: "Updates available! Pull to refresh")
			}, completion: {
				self.viewModel.newBulletinsAvailable = false
			})
			.animation(.easeInOut, value: self.viewModel.bulletins)
			.animation(.easeInOut, value: self.viewModel.isLoading)
			.animation(.easeInOut, value: self.viewModel.isError)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.onCfgChanged(onChanged: { cfgType, _ in
				if cfgType == .avatar {
					self.avatarId = Date()
				}
			})
			.onAppear {
				self.avatarId = Date()
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.editor)
			.navigationTitle("Bulletin")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: UserProfileView()) {
						Avatar(type: .userCfg, size: .xs, state: .normal)
							.id(self.avatarId)
					}
				}
			}
		}
		.tint(.blue)
	}
}
