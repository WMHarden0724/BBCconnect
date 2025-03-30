//
//  HomeTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import AlertToast

struct HomeTabView : View {
	
	@StateObject private var viewModel = BulletinsViewModel()
	
	@State private var showNewBulletinsAvailable = false
	@State private var alertToastError: String?
	@State private var avatarId = Date()
	
	var body: some View {
		NavigationStack {
			ZStack {
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
				}
				.listStyle(.plain)
				.refreshable {
					self.viewModel.fetchBulletins(reset: true)
				}
				.toast(isPresenting: self.$viewModel.newBulletinsAvailable, duration: 5, offsetY: 60, alert: {
					AlertToast(displayMode: .hud, type: .complete(Color.blue), title: "Updates available! Pull to refresh")
				}, completion: {
					self.viewModel.newBulletinsAvailable = false
				})
				
				if self.viewModel.bulletins.isEmpty {
					VStack {
						Spacer()
						
						Text("No bulletins")
							.font(.headline)
							.foregroundColor(.primary)
							.frame(maxWidth: .infinity)
						
						Spacer()
					}
				}
				
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
					.opacity(self.viewModel.loadingState.isLoading ? 1 : 0)
			}
			.animation(.easeInOut, value: self.viewModel.bulletins)
			.animation(.easeInOut, value: self.viewModel.loadingState)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.onCfgChanged(onChanged: { cfgType, _ in
				if cfgType == .avatar {
					self.avatarId = Date()
				}
			})
			.toast(isPresenting: Binding(
				get: { self.alertToastError != nil },
				set: { if !$0 { self.alertToastError = nil } }
			), duration: 5, offsetY: 60, alert: {
				AlertToast(displayMode: .hud, type: .error(Color.errorMain), title: self.alertToastError ?? "")
			}, completion: {
				self.alertToastError = nil
			})
			.onChange(of: self.viewModel.loadingState, initial: false) {
				if case .failure(let error) = self.viewModel.loadingState {
					self.alertToastError = error.localizedDescription
				}
			}
			.onAppear {
				self.avatarId = Date()
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.editor)
			.navigationTitle(Date.now.formatted(.dateTime.month().day().year()))
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
