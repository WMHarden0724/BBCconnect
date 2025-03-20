//
//  ConversationItemView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI
import SwipeActions

struct ConversationItemView : View {
	
	let conversation: Conversation
	var onOpen: () -> Void
	var onLeaveConversation: () -> Void
	
	@State private var showLeaveAlert = false
	@State private var swipeActionContext: SwipeContext?
	@State private var avatarSize: CGSize = .zero
	
	var body: some View {
		SwipeView {
			Button(action: {
				self.onOpen()
			}) {
				VStack {
					HStack(spacing: Dimens.horizontalPadding) {
						
						AvatarGroup(items: self.conversation.users.filter { $0.id != UserCfg.userId() }.map { AvatarType.image($0) },
									size: 40)
						.readSize { size in
							self.avatarSize = size
						}
						
						VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
							HStack(spacing: 0) {
								
								Text(self.conversation.last_message.user.fullName())
									.font(.headline)
									.foregroundColor(.textPrimary)
									.lineLimit(1)
									.frame(maxWidth: .infinity, alignment: .leading)
								
								if let dateString = Date.formatConversationLastMessageDate(dateString: self.conversation.last_message.updated_at) {
									Text(dateString)
										.font(.caption)
										.foregroundColor(.textSecondary)
										.padding(.leading, Dimens.horizontalPadding)
								}
								
								Image(systemName: "chevron.right")
									.imageScale(.medium)
									.foregroundColor(.actionActive)
									.padding(.leading, Dimens.horizontalPaddingSm)
							}
							
							// Last message or placeholder text
							Text(self.conversation.last_message.content)
								.font(.subheadline)
								.foregroundColor(.textSecondary)
								.lineLimit(2)
								.truncationMode(.tail)
								.frame(maxWidth: .infinity, minHeight: UIFont.preferredFont(forTextStyle: .subheadline).lineHeight * 2, alignment: .topLeading)
						}
					}
					.padding(.leading, Dimens.horizontalPaddingXl)
					.padding(.trailing, Dimens.horizontalPadding)
					.padding(.top, Dimens.verticalPadding)
					.padding(.bottom, Dimens.verticalPaddingXxsm)
					
					Divider()
						.foregroundColor(.divider)
						.padding(.leading, (Dimens.horizontalPadding * 2) + self.avatarSize.width)
				}
				.overlay(alignment: .leading) {
					AvatarBadge(
						size: 10,
						state: .unread
					)
					.padding(.leading, (Dimens.horizontalPaddingXl / 2) - 5)
					.opacity(self.conversation.unread_count > 0 ? 1 : 0)
				}
			}
		} trailingActions: { context in
			SwipeAction(systemImage: "trash.fill", backgroundColor: .errorMain) {
				self.showLeaveAlert.toggle()
				self.swipeActionContext = context
			}
			.allowSwipeToTrigger()
			.foregroundColor(.errorContrast)
		}
		.swipeActionCornerRadius(0)
		.swipeActionsMaskCornerRadius(0)
		.swipeMinimumDistance(50)
		.alert("Leave conversation?", isPresented: self.$showLeaveAlert) {
			Button("Cancel", role: .cancel) {
				self.swipeActionContext?.state.wrappedValue = .closed
				self.swipeActionContext = nil
			}
			Button("Leave", role: .destructive) {
				self.onLeaveConversation()
				self.swipeActionContext?.state.wrappedValue = .closed
				self.swipeActionContext = nil
			}
		} message: {
			if conversation.owner_id == UserCfg.userId() {
				Text("Are you sure you want to proceed? Since you own this conversation, ownership will pass to the next available user. If no other users exist, this conversation will be removed")
			}
			else {
				Text("Are you sure you want to proceed?")
			}
		}
	}
}
