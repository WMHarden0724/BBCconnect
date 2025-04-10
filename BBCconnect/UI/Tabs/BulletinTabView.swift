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
				ForEach(self.viewModel.bulletins, id: \._id) { bulletin in
					BulletinListItem(bulletin: bulletin)
						.padding(.leading, Dimens.horizontalPadding)
						.padding(.trailing, Dimens.horizontalPadding)
						.padding(.top, self.viewModel.bulletins.firstIndex(where: { $0._id == bulletin._id }) == 0 ? Dimens.verticalPaddingLg : 0)
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
					Text("No bulletins available")
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
						self.viewModel.fetchBulletins()
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
				self.viewModel.fetchBulletins(reset: true)
			}
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
