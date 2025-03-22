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
	
	@State private var viewSize: CGSize = .zero
	@State private var inputText: String = ""
	@State private var searchQuery: String = ""
	@State private var message = ""
	
	@State private var alertToastError: String?
	
	var filteredUsers: [User] {
		let users = self.searchViewModel.users
		return users.filter { !self.viewModel.conversation.users.contains($0) }
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				ScrollView {
					VStack {
						Spacer()
						
						Text("")
							.frame(maxWidth: .infinity)
					}
					.applyHorizontalPadding(viewWidth: self.viewSize.width)
					.padding(.vertical, Dimens.verticalPadding)
				}
				.searchable(text: self.$inputText,
							tokens: self.$selectedUsers,
							token: { user in
					Text(user.fullName())
				})
				.searchPresentationToolbarBehavior(.avoidHidingContent)
				.searchSuggestions({
					ForEach(self.filteredUsers) { user in
						Button {
							self.selectedUsers.append(user)
							self.inputText.removeAll()
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
						}
					}
				})
				.onChange(of: self.inputText, initial: false) {
					self.search()
				}
			}
			.animation(.easeInOut(duration: 0.25), value: self.message)
			.readSize { size in
				self.viewSize = size
			}
			.toast(isPresenting: Binding(
				get: { self.alertToastError != nil },
				set: { if !$0 { self.alertToastError = nil } }
			), alert: {
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
	
	private func search() {
		let components = self.inputText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
		self.searchQuery = components.last ?? ""
		
		if self.searchQuery.isEmpty {
			self.searchViewModel.users.removeAll()
			return
		}
		
		Task {
			await self.searchViewModel.searchUsers(query: self.searchQuery)
		}
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
