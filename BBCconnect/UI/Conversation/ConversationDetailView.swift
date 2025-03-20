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
	
	@State private var bottomAnchorId = Date()
	@State private var alertToastError: String?
	@State private var isShowingInfoView = false
	@State private var typingCancellable: AnyCancellable?
	
	private var navTitle: String {
		let users = self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() }
		if users.count > 1 {
			return "\(users.count) People"
		}
		else {
			return users[0].first_name
		}
	}
	
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
								if let timestamp = self.getPreviousMessageTimestamp(message: message) {
									Text(timestamp)
										.font(.footnote)
										.foregroundColor(.textSecondary)
										.padding(.top, Dimens.verticalPaddingMd)
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
								TypingBubbleView(user: userTyping,
												 shouldShowParticipantInfo: self.viewModel.conversation.users.count > 2)
									.padding(.horizontal, Dimens.horizontalPadding)
									.padding(.bottom, Dimens.verticalPaddingSm)
									.transition(.move(edge: .bottom).combined(with: .opacity))
							}
						}
						.id(self.bottomAnchorId)
						.padding(.top, Dimens.verticalPadding)
						.onChange(of: self.viewModel.userTyping, initial: false) {
							if self.viewModel.userTyping != nil {
								proxy.scrollTo(self.bottomAnchorId, anchor: .bottom)
							}
						}
						.onChange(of: self.viewModel.messages, initial: true) {
							if self.viewModel.messages.last != nil {
								proxy.scrollTo(self.bottomAnchorId, anchor: .bottom)
							}
						}
					}
				}
				.defaultScrollAnchor(.bottom)
				.animation(.easeInOut, value: self.viewModel.userTyping)
				.animation(.easeInOut, value: self.viewModel.messages)
				
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
			.animation(.easeInOut, value: self.viewModel.conversation)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.sheet(isPresented: self.$isShowingInfoView) {
				ConversationInfoView(viewModel: self.viewModel) {
					self.dismiss()
				}
			}
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
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button(action: {
						self.dismiss()
					}) {
						Image(systemName: "xmark")
							.tint(.blue)
							.imageScale(.medium)
					}
				}
				
				ToolbarItem(placement: .principal) {
					Button(action: {
						self.isShowingInfoView.toggle()
					}) {
						VStack {
							if self.viewModel.conversation.users.count == 1 {
								Avatar(type: .image(self.viewModel.conversation.users[0]), size: .xxs, state: .normal)
							}
							else {
								AvatarGroup(users: self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() },
											size: 24,
											includeBackground: false)
							}
							
							HStack(spacing: 2) {
								Text(self.navTitle)
									.foregroundColor(.textPrimary)
									.font(.caption)
								
								Image(systemName: "chevron.right")
									.font(.system(size: 8))
									.foregroundColor(.actionActive)
							}
						}
					}
				}
			}
		}
	}
	
	private func getPreviousMessageTimestamp(message: ConversationMessage) -> String? {
		let index = self.viewModel.messages.firstIndex(of: message) ?? 0
		var shouldShowHeader = index == 0
		var previousDate: Date?
		
		
		if index > 0 {
			previousDate = self.viewModel.messages[index - 1].createdAtDate
		}
		
		if let previousDate = previousDate, let date = message.createdAtDate {
			shouldShowHeader = date.timeIntervalSince(previousDate) > 7200 // 2 hours
		}
		
		if shouldShowHeader, let createdAtTimestamp = message.createdAtTimestamp() {
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
			self.hideKeyboard()
			self.typingCancellable?.cancel()
			self.viewModel.setTyping(typing: false)
			if let error = await self.viewModel.createMessage(message: self.message) {
				DispatchQueue.main.async {
					self.alertToastError = error
				}
			}
			else {
				DispatchQueue.main.async {
					self.message = ""
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
			.delay(for: .seconds(2), scheduler: RunLoop.main)
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
