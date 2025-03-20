//
//  ConversationDetailView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import Combine
import AlertToast

struct ConversationDetailView: View {
	
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
							Spacer(minLength: Dimens.verticalPadding)
							
							ForEach(self.viewModel.messages.indices, id: \.self) { index in
								let message = self.viewModel.messages[index]
								
								if let timestamp = self.getPreviousMessageTimestamp(index: index) {
									Text(timestamp)
										.font(.footnote)
										.foregroundColor(.textSecondary)
										.padding(.top, index == 0 ? 0 : Dimens.verticalPaddingMd)
										.padding(.bottom, Dimens.verticalPaddingSm)
								}
								
								ConversationMessageView(message: message,
														isFromYou: message.user.id == UserCfg.userId(),
														shouldShowParticipantInfo: self.viewModel.conversation.users.count > 2)
								.padding(.horizontal, Dimens.horizontalPadding)
								.padding(.bottom, Dimens.verticalPaddingSm)
								.padding(.leading, message.user.id == UserCfg.userId() ? self.viewSize.width * 0.2 : 0)
								.padding(.trailing, message.user.id != UserCfg.userId() ? self.viewSize.width * 0.2 : 0)
							}
							
							if let userTyping = self.viewModel.userTyping {
								TypingBubbleView(user: userTyping)
									.padding(.horizontal, Dimens.horizontalPadding)
							}
							else if self.viewModel.isTyping {
								TypingBubbleView()
									.padding(.horizontal, Dimens.horizontalPadding)
							}
							
							Spacer(minLength: Dimens.verticalPaddingSm)
								.id(self.bottomSpacerId)
						}
						.onChange(of: self.viewModel.isTyping, initial: false) {
							if self.viewModel.isTyping {
								proxy.scrollTo(self.bottomSpacerId, anchor: .bottom)
							}
						}
						.onChange(of: self.viewModel.userTyping, initial: false) {
							if self.viewModel.userTyping != nil {
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
					.padding(.horizontal, Dimens.horizontalPadding)
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
			.animation(.easeInOut, value: self.viewModel.isTyping)
			.animation(.easeInOut, value: self.viewModel.userTyping)
			.animation(.easeInOut, value: self.viewModel.messages)
			.animation(.easeInOut, value: self.viewModel.conversation)
			.navigationTitle(self.viewModel.conversation.name)
			.navigationBarTitleDisplayMode(.inline)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.onChange(of: self.viewModel.messages, initial: false) {
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
						ForEach(self.viewModel.conversation.sortedUsers, id: \.id) {
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
						AvatarGroup(items: self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() }.map { AvatarType.image($0) },
									size: 24)
					}
				}
			}
		}
	}
	
	private func getPreviousMessageTimestamp(index: Int) -> String? {
		var shouldShowHeader = index == 0
		var previousDate: Date?
		
		if index > 0 {
			previousDate = self.viewModel.messages[index - 1].createdAtDate
		}
		
		if let previousDate = previousDate, let date = self.viewModel.messages[index].createdAtDate {
			shouldShowHeader = date.timeIntervalSince(previousDate) > 7200 // 2 hours
		}
		
		if shouldShowHeader, let createdAtTimestamp = self.viewModel.messages[index].createdAtTimestamp() {
			return createdAtTimestamp
		}
		
		return nil
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
					self.typingCancellable?.cancel()
					self.viewModel.setTyping(typing: false)
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
			.delay(for: .seconds(3), scheduler: RunLoop.main)
			.sink { _ in
				self.viewModel.setTyping(typing: false)
			}
	}
}

struct ConversationView_Previews: PreviewProvider {
	static var previews: some View {
		ConversationDetailView(viewModel: MockConversationViewModel())
	}
}
