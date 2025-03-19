//
//  ConversationView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import Combine
import AlertToast

struct ConversationView: View {
	
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel: ConversationViewModel
	
	@State private var message = ""
	@State private var viewSize: CGSize = .zero
	
	@State private var bottomSpacerId = Date()
	@State private var alertToastError: String?
	@State private var showLeaveConversationAlert = false
	@State private var typingCancellable: AnyCancellable?
	
	init(viewModel: ConversationViewModel) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}
	
	init(conversation: Conversation) {
		_viewModel = StateObject(
			wrappedValue: ConversationViewModel(conversation: conversation))
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				ScrollView {
					ScrollViewReader { proxy in
						LazyVStack(spacing: 0) {
							ForEach(self.viewModel.messages, id: \.id) { message in
								VStack {
									if let dateString = Date.formatConversationMessageDate(dateString: message.updated_at) {
										Text(dateString)
											.font(.caption)
											.foregroundColor(.textSecondary)
									}
									
									ConversationMessageView(message: message)
								}
								.padding(.bottom, Dimens.verticalPaddingSm)
								.applyHorizontalPadding(viewWidth: self.viewSize.width)
							}
							
							if self.viewModel.isTypingIndicated {
								HStack {
									Text("...")
										.conversationMessageBubbleStyle(isFromYou: false)
									
									Spacer()
								}
							}
							
							Spacer(minLength: Dimens.verticalPaddingSm)
								.id(self.bottomSpacerId)
						}
						.onChange(of: self.viewModel.isTypingIndicated, initial: false) {
							if self.viewModel.isTypingIndicated {
								proxy.scrollTo(self.bottomSpacerId, anchor: .bottom)
							}
						}
						.onChange(of: self.viewModel.messages, initial: true) {
							if self.viewModel.messages.last != nil {
								proxy.scrollTo(self.bottomSpacerId, anchor: .bottom)
							}
						}
					}
				}
				.defaultScrollAnchor(.bottom)
				
				VStack {
					Divider().foregroundColor(.divider)
					
					ConversationTextField(message: self.$message) {
						self.addMessage()
					}
					.applyHorizontalPadding(viewWidth: self.viewSize.width)
					.onChange(of: self.message, initial: false) {
						self.viewModel.setTyping(typing: true)
						self.debounceMessageChange()
					}
				}
				.backgroundIgnoreSafeArea()
			}
			.readSize { size in
				self.viewSize = size
			}
			.animation(.easeInOut, value: self.viewModel.isTypingIndicated)
			.animation(.easeInOut, value: self.viewModel.messages)
			.animation(.easeInOut, value: self.viewModel.conversation)
			.navigationTitle(self.viewModel.conversation.name)
			.navigationBarTitleDisplayMode(.inline)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.onChange(of: self.viewModel.messages, initial: true) {
				self.markMessagesAsRead()
			}
			.toast(isPresenting: Binding(
				get: { self.alertToastError != nil },
				set: { if !$0 { self.alertToastError = nil } }
			), alert: {
				AlertToast(type: .error(Color.errorMain), title: self.alertToastError ?? "")
			}, completion: {
				self.alertToastError = nil
			})
			.alert("Leave conversation?", isPresented: self.$showLeaveConversationAlert) {
				Button("Leave", role: .destructive) {
					self.leaveConversation()
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				if self.viewModel.conversation.owner_id == UserCfg.userId() {
					Text("Are you sure you want to proceed? Since you own this conversation, ownership will pass to the next available user. If no other users exist, this conversation will be removed")
				}
				else {
					Text("Are you sure you want to proceed?")
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
				
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						ForEach(self.viewModel.conversation.users, id: \.id) {
							user in
							Button(action: {
								self.showLeaveConversationAlert.toggle()
							}) {
								if user.id == UserCfg.userId() {
									Text("\(user.fullName()) (You)")
										.foregroundColor(.textPrimary)
								} else {
									Text(user.fullName())
										.foregroundColor(.textPrimary)
								}
							}
							.disabled(user.id != UserCfg.userId())
						}
					} label: {
						AvatarGroup(items: self.viewModel.conversation.users.map { AvatarType.image($0) },
									size: .sm,
									state: .normal)
					}
				}
			}
		}
	}
	
	private func markMessagesAsRead() {
		Task {
			await self.viewModel.markAsRead()
		}
	}
	
	private func addMessage() {
		Task {
			if let error = await self.viewModel.createMessage(message: self.message) {
				DispatchQueue.main.async {
					self.alertToastError = error
					self.hideKeyboard()
				}
			}
			else {
				DispatchQueue.main.async {
					self.message = ""
					self.hideKeyboard()
				}
			}
		}
	}
	
	private func leaveConversation() {
		Task {
			let result = await self.viewModel.leaveConversation()
			DispatchQueue.main.async {
				if result.0 {
					self.dismiss()
				}
				else {
					self.alertToastError = result.1
				}
			}
		}
	}
	
	private func debounceMessageChange() {
		self.typingCancellable?.cancel()
		self.typingCancellable = Just(self.message)
			.delay(for: .seconds(0.5), scheduler: RunLoop.main)
			.sink { _ in
				self.viewModel.setTyping(typing: false)
			}
	}
}

struct ConversationView_Previews: PreviewProvider {
	static var previews: some View {
		ConversationView(viewModel: MockConversationViewModel())
	}
}
