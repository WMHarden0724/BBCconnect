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
	
	@State private var alertToastError: String?
	@State private var isShowingInfoView = false
	@State private var typingCancellable: AnyCancellable?
	
	@State private var userTyping: User?
	@State private var userTypingId = Date()
	
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
		VStack(spacing: 0) {
			ScrollView {
				LazyVStack(spacing: 0) {
					ForEach(self.viewModel.messages, id: \.id) { message in
						if let timestamp = self.getPreviousMessageTimestamp(message: message) {
							Text(timestamp)
								.font(.footnote)
								.foregroundColor(.secondary)
								.padding(.top, Dimens.verticalPaddingMd)
								.padding(.bottom, Dimens.verticalPaddingSm)
						}

						let showOwnerName = self.shouldShowMessageOwnerName(message: message)
						ConversationMessageView(message: message,
												isFromYou: message.user.id == UserCfg.userId(),
												shouldShowParticipantInfo: self.viewModel.conversation.users.count > 2,
												showOwnerName: showOwnerName,
												participantOpacity: self.showParticipantInfo(message: message) ? 1 : 0)
						.padding(.horizontal, Dimens.horizontalPadding)
						.padding(.top, showOwnerName ? Dimens.verticalPaddingMd : 0)
						.padding(.bottom, Dimens.verticalPaddingSm)
						.padding(.leading, message.user.id == UserCfg.userId() ? self.viewSize.width * 0.2 : 0)
						.padding(.trailing, message.user.id != UserCfg.userId() ? self.viewSize.width * 0.2 : 0)
					}

					if let userTyping = self.userTyping {
						TypingBubbleView(user: userTyping,
										 shouldShowParticipantInfo: self.viewModel.conversation.users.count > 2)
						.padding(.horizontal, Dimens.horizontalPadding)
						.padding(.bottom, Dimens.verticalPaddingSm)
						.transition(.move(edge: .bottom).combined(with: .opacity))
					}
				}
				.padding(.top, Dimens.verticalPadding)
			}
			.defaultScrollAnchor(.bottom)
			
			ConversationTextField(message: self.$message) {
				self.addMessage()
			}
			.padding(.horizontal, Dimens.horizontalPadding)
			.padding(.bottom, Dimens.verticalPadding)
			.backgroundIgnoreSafeArea(color: .backgroundDark)
			.onChange(of: self.message, initial: false) {
				self.viewModel.setTyping(typing: true)
				self.debounceMessageChange()
			}
		}
		.readSize { size in
			self.viewSize = size
		}
		.animation(.easeInOut, value: self.viewModel.messages)
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
		.onChange(of: self.viewModel.userTyping, initial: false) {
			withAnimation(.easeInOut(duration: 0.3)) {
				self.userTyping = self.viewModel.userTyping
			}
		}
		.toast(isPresenting: Binding(
			get: { self.alertToastError != nil },
			set: { if !$0 { self.alertToastError = nil } }
		), alert: {
			AlertToast(type: .error(Color.errorMain), title: self.alertToastError ?? "")
		}, completion: {
			self.alertToastError = nil
		})
		.toolbar(.hidden, for: .tabBar)
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
		.toolbarRole(.editor)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Button(action: {
					self.isShowingInfoView.toggle()
				}) {
					HStack(spacing: 2) {
						let users = self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() }
						if users.count == 1 {
							Avatar(type: .image(users[0]), size: .custom(32), state: .normal)
						}
						else {
							AvatarGroup(users: users,
										width: 60,
										height: 38,
										includeBackground: false)
						}
						
						Image(systemName: "chevron.right")
							.font(.system(size: 7))
							.foregroundColor(.actionActive)
					}
				}
				.buttonStyle(.plain)
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
	
	private func shouldShowMessageOwnerName(message: ConversationMessage) -> Bool {
		guard self.viewModel.conversation.users.count > 2 else { return false }
		guard message.user.id != UserCfg.userId() else { return false }
		
		guard let index = self.viewModel.messages.firstIndex(of: message) else {
			return false
		}
		
		if index == 0 {
			return true
		}
		
		let previousMessage = self.viewModel.messages[index - 1]
		if previousMessage.user.id != message.user.id {
			return true
		}
		
		if let date1 = previousMessage.createdAtDate, let date2 = message.createdAtDate {
			let differenceInMinutes = abs(date1.timeIntervalSince(date2)) / 60
			return differenceInMinutes > 30
		}
		
		return false
	}
	
	private func showParticipantInfo(message: ConversationMessage) -> Bool {
		guard self.viewModel.conversation.users.count > 2 else { return false }
		guard let index = self.viewModel.messages.firstIndex(of: message) else {
			return true
		}
		
		if index < (self.viewModel.messages.count - 1) {
			let nextMessage = self.viewModel.messages[index + 1]
			
			if let date1 = message.createdAtDate, let date2 = nextMessage.createdAtDate {
				let differenceInMinutes = abs(date1.timeIntervalSince(date2)) / 60
				return differenceInMinutes > 30
			}
			
			return nextMessage.user.id != message.user.id
		}
		
		return true
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
