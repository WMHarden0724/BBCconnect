//
//  NewConversationView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI

struct NewConversationView : View {
	
	@Environment(\.dismiss) var dismiss
	
	@StateObject private var viewModel = NewConversationViewModel()
	
	@State private var selectedUsers = [User]()
	
	@State private var viewSize: CGSize = .zero
	@State private var inputText: String = ""
	@State private var searchQuery: String = ""
	@State private var message = ""
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					HStack(spacing: 2) {
						Text("To:")
							.foregroundColor(.textSecondary)
							.font(.body)
						
						TextField("", text: self.$inputText)
							.textInputAutocapitalization(.sentences)
							.textFieldStyle(PlainTextFieldStyle())
							.padding(.horizontal, 12)
							.padding(.vertical, 10)
							.foregroundColor(.textPrimary)
							.onChange(of: self.inputText, initial: false) { _, _ in
								self.search()
							}
					}
					.applyHorizontalPadding(viewWidth: self.viewSize.width)
					
					Divider().foregroundColor(.divider)
				}
				.background(Color.background)
				
				ScrollView {
					VStack {
						if !self.viewModel.users.isEmpty {
							ForEach(self.viewModel.users, id: \.id) { user in
								VStack {
									Button(action: {
										self.addUserToTextField(user)
									}) {
										HStack(spacing: Dimens.horizontalPadding) {
											Avatar(type: .image(user), size: .sm, state: .normal)
											
											VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
												Text(user.fullName())
													.font(.body)
													.foregroundColor(.textPrimary)
												
												Text(user.email)
													.font(.caption)
													.foregroundColor(.textSecondary)
											}
											
											Spacer()
										}
									}
									
									Divider().foregroundColor(.divider)
								}
								.transition(.opacity)
							}
						}
					}
					.applyHorizontalPadding(viewWidth: self.viewSize.width)
					.padding(.vertical, Dimens.verticalPadding)
				}
				
				Spacer()
				
				VStack {
					Divider().foregroundColor(.divider)
					
					ConversationTextField(message: self.$message) {
						self.createConversation()
					}
					.applyHorizontalPadding(viewWidth: self.viewSize.width)
				}
				.backgroundIgnoreSafeArea()
			}
			.animation(.easeInOut(duration: 0.25), value: self.message)
			.animation(.easeInOut, value: self.viewModel.users)
			.readSize { size in
				self.viewSize = size
			}
			.navigationTitle("New conversation")
			.navigationBarTitleDisplayMode(.inline)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.onChange(of: self.viewModel.loadingState, initial: false) { _, _ in
				if case .success(_) = self.viewModel.loadingState {
					self.dismiss()
				}
				else if case .failure(let error) = self.viewModel.loadingState {
					// TODO: show error
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button(action: {
						self.dismiss()
					}) {
						Image(systemName: "xmark")
							.tint(.actionActive)
							.imageScale(.medium)
					}
				}
			}
		}
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
	
	private func addUserToTextField(_ user: User) {
		self.selectedUsers.append(user)
		
		var components = inputText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
		if !components.isEmpty {
			components[components.count - 1] = user.fullName()
		} else {
			components.append(user.fullName())
		}
		
		self.inputText = components.joined(separator: ", ") + ", "
		self.viewModel.users.removeAll()
	}
	
	private func createConversation() {
		self.viewModel.createConversation(users: self.selectedUsers, message: self.message)
	}
}

struct NewConversationView_Previews: PreviewProvider {
	static var previews: some View {
		NewConversationView()
	}
}
