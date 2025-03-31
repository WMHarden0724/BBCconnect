//
//  NewConversationView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import AlertToast

struct NewConversationView : View {
	
	@Environment(\.dismiss) var dismiss
	
	@StateObject private var viewModel = NewConversationViewModel()
	
	@State private var selectedUsers = [User]()
	
	@State private var viewSize: CGSize = .zero
	@State private var message = ""
	
	@State private var alertToastError: String?
	
	var onConversationCreated: (Conversation) -> Void
	
	private var filteredUsers: [User] {
		let users = self.viewModel.users
		return users.filter { !self.selectedUsers.contains($0) && $0.id != UserCfg.userId() }
	}
	
	init(onConversationCreated: @escaping (Conversation) -> Void) {
		self.onConversationCreated = onConversationCreated
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				List {
					ForEach(self.filteredUsers) { user in
						Button {
							self.selectedUsers.append(user)
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
							if user == self.viewModel.users.last {
								self.viewModel.searchUsers(query: self.viewModel.searchQuery)
							}
						}
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
						Text("Failed to load users")
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
					else if self.filteredUsers.isEmpty {
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
					self.viewModel.searchUsers(reset: true, query: self.viewModel.searchQuery)
				}
				.searchable(text: self.$viewModel.searchQuery,
							tokens: self.$selectedUsers,
							prompt: "Search users by name or email",
							token: { user in
					Text(user.fullName())
				})
				.searchPresentationToolbarBehavior(.avoidHidingContent)
				
				Spacer()
				
				ConversationTextField(message: self.$message) {
					self.createConversation()
				}
				.applyHorizontalPadding(viewWidth: self.viewSize.width)
				.padding(.bottom, Dimens.verticalPadding)
				.backgroundIgnoreSafeArea(color: .backgroundDark)
			}
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
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.navigationTitle("New Message")
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.automatic)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						self.dismiss()
					}) {
						Text("Cancel")
							.foregroundStyle(.blue)
							.font(.system(size: 17, weight: .medium))
					}
				}
			}
		}
		.tint(.blue)
	}
	
	private func createConversation() {
		Task {
			let result = await self.viewModel.createConversation(users: self.selectedUsers, message: self.message)
			DispatchQueue.main.async {
				if let conversation = result.0 {
					self.onConversationCreated(conversation)
					self.dismiss()
				}
				else if let error = result.1 {
					self.alertToastError = error
				}
			}
		}
	}
}

struct NewConversationView_Previews: PreviewProvider {
	static var previews: some View {
		NewConversationView { _ in }
	}
}
