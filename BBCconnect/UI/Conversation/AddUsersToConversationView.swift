//
//  NewConversationView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import AlertToast

struct AddUsersToConversationView : View {
	
	@Environment(\.dismiss) var dismiss
	
	@ObservedObject var viewModel: ConversationViewModel
	@StateObject private var searchViewModel = UserSearchViewModel()
	
	@State private var selectedUsers = [User]()
	@State private var searchQuery = ""
	
	@State private var viewSize: CGSize = .zero
	@State private var message = ""
	
	@State private var alertToastError: String?
	
	var filteredUsers: [User] {
		let users = self.searchViewModel.users
		return users.filter {
			!self.viewModel.conversation.users.contains($0) && !self.selectedUsers.contains($0)
		}
	}
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(self.filteredUsers) { user in
					Button {
						self.selectedUsers.append(user)
						self.searchQuery.removeAll()
					} label: {
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
					}
					.onAppear {
						if user == self.searchViewModel.users.last {
							self.searchViewModel.searchUsers(query: self.searchQuery)
						}
					}
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.listRowSpacing(0)
					.listRowInsets(EdgeInsets())
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
					Text("Failed to load users.")
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
				else if self.searchViewModel.users.isEmpty {
					Text("No users match your filter criteria")
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
			}
			.listStyle(.plain)
			.refreshable {
				self.searchViewModel.searchUsers(reset: true, query: self.searchQuery)
			}
			.searchable(text: self.$searchQuery,
						tokens: self.$selectedUsers,
						prompt: "Filter users by name or email",
						token: { user in
				Text(user.fullName())
			})
			.searchPresentationToolbarBehavior(.avoidHidingContent)
			.onChange(of: self.searchQuery, initial: false) {
				self.searchViewModel.searchUsers(reset: true, query: self.searchQuery)
			}
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
			.navigationTitle("Group")
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.automatic)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button(action: {
						self.dismiss()
					}) {
						Text("Cancel")
							.foregroundStyle(.blue)
							.font(.system(size: 17, weight: .medium))
					}
				}
				
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						self.updateConversation()
					}) {
						Text("Done")
							.foregroundColor(self.selectedUsers.isEmpty ? .gray.opacity(0.5) : .blue)
							.font(.system(size: 17, weight: .medium))
					}
					.disabled(self.selectedUsers.isEmpty)
				}
			}
		}
		.tint(.blue)
	}
	
	private func updateConversation() {
		Task {
			let result = await self.viewModel.addUsersToConversation(newUsers: self.selectedUsers)
			DispatchQueue.main.async {
				if result.0 {
					self.dismiss()
				}
				else if let error = result.1 {
					self.alertToastError = error
				}
			}
		}
	}
}
