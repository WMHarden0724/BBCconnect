//
//  MembersTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import AlertToast

struct MembersTabView : View {
	
	@StateObject private var searchViewModel = UserSearchViewModel()
	
	@State private var viewSize: CGSize = .zero
	@State private var message = ""
	
	@State private var alertToastError: String?
	
	private var emptyText: String {
		if !self.searchViewModel.searchQuery.isEmpty && self.searchViewModel.showPending {
			return "No pending members match your search criteria"
		}
		else if !self.searchViewModel.searchQuery.isEmpty {
			return "No members match your search criteria"
		}
		else if self.searchViewModel.showPending {
			return "No pending members"
		}
		else {
			return "No members"
		}
	}
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(self.searchViewModel.groupedUsers.keys.sorted(), id: \.self) { userGroup in
					if let users = self.searchViewModel.groupedUsers[userGroup] {
						Section(
							header: Text(userGroup)
									.foregroundColor(.secondary)
									.font(.headline)
						) {
							ForEach(users, id: \.id) { user in
								ZStack {
									HStack(spacing: Dimens.horizontalPadding) {
										Avatar(type: .image(user), size: .sm, state: .normal)
										
										VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
											Text(user.fullName())
												.font(.body)
												.foregroundColor(.primary)
											
											Text(user.email)
												.font(.caption)
												.foregroundColor(.secondary)
										}
										
										Spacer()
									}
									.padding(.horizontal, Dimens.horizontalPadding)
									.padding(.bottom, Dimens.verticalPaddingMd)
									NavigationLink(destination: MemberDetailsView(user: user)) {
										EmptyView()
									}.opacity(0)
								}
								.listRowSeparator(.hidden)
								.listRowBackground(Color.clear)
								.listRowSpacing(0)
								.listRowInsets(EdgeInsets())
							}
						}
					}
				}
				
				if self.searchViewModel.isLoading {
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
				else if self.searchViewModel.isError {
					Text("Failed to load members")
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
				else if self.searchViewModel.groupedUsers.isEmpty {
					Text(self.emptyText)
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
				else if self.searchViewModel.canLoadMore {
					Button(action: {
						self.searchViewModel.searchUsers(query: self.searchViewModel.searchQuery)
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
			.scrollContentBackground(.hidden)
			.refreshable {
				self.searchViewModel.searchUsers(reset: true, query: self.searchViewModel.searchQuery)
			}
			.searchable(text: self.$searchViewModel.searchQuery,
						prompt: "Search users by name, email, or role")
			.searchPresentationToolbarBehavior(.avoidHidingContent)
			.animation(.easeInOut, value: self.searchViewModel.users)
			.animation(.easeInOut, value: self.searchViewModel.isLoading)
			.animation(.easeInOut, value: self.searchViewModel.isError)
			.animation(.easeInOut(duration: 0.25), value: self.message)
			.readSize { size in
				self.viewSize = size
			}
			.toast(isPresenting: Binding(
				get: { self.alertToastError != nil },
				set: { if !$0 { self.alertToastError = nil } }
			), duration: 5, offsetY: 60, alert: {
				AlertToast(displayMode: .hud, type: .error(Color.errorMain), title: self.alertToastError ?? "")
			}, completion: {
				self.alertToastError = nil
			})
			.navigationTitle("Members")
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.automatic)
			.backgroundIgnoreSafeArea(color: .background)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					HStack {
						Menu {
							ForEach(UserSearchViewModel.UserSearchSortOption.allCases, id: \.self) { option in
								Button(action: {
									self.searchViewModel.sortOption = option
								}) {
									Label(option.uiName, systemImage: self.searchViewModel.sortOption == option ? "checkmark" : "")
								}
							}
							
							Button(action: {
								self.searchViewModel.showPending.toggle()
							}) {
								Label("View Pending Users", systemImage: self.searchViewModel.showPending ? "eye" : "")
							}
						} label: {
							Image(systemName: "line.3.horizontal.decrease.circle")
								.imageScale(.large)
								.foregroundColor(.primaryMain)
						}
					}
				}
			}
		}
		.tint(.primaryMain)
	}
}
