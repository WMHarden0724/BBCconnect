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
	@State private var inputText: String = ""
	@State private var searchQuery: String = ""
	@State private var message = ""
	
	@State private var alertToastError: String?
	
	var onConversationCreated: (Conversation) -> Void
	
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
				.searchSuggestions({
					ForEach(self.viewModel.users) { user in
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
			), alert: {
				AlertToast(type: .error(Color.errorMain), title: self.alertToastError ?? "")
			}, completion: {
				self.alertToastError = nil
			})
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.navigationTitle("New Message")
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(Color.clear, for: .navigationBar)
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
	
	private func search() {
		let components = self.inputText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
		self.searchQuery = components.last ?? ""
		
		if self.searchQuery.isEmpty {
			self.viewModel.users.removeAll()
			return
		}
		
		Task {
			await self.viewModel.searchUsers(query: self.searchQuery)
		}
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
