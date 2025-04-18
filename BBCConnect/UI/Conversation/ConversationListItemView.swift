//
//  ConversationListItemView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI
import SwipeActions

struct ConversationListItemView : View {
	
	let conversation: Conversation
	var onLeaveConversation: () -> Void
	
	@State private var showLeaveAlert = false
	@State private var swipeActionContext: SwipeContext?
	@State private var avatarSize: CGSize = .zero
	
	var body: some View {
		SwipeView {
			VStack {
				HStack(spacing: Dimens.horizontalPadding) {
					
					if self.conversation.users.count == 1 {
						Avatar(type: .image(self.conversation.users[0]), size: .custom(40), state: .normal)
							.readSize { size in
								self.avatarSize = size
							}
					}
					else {
						AvatarGroup(users: self.conversation.users.filter { $0.id != UserCfg.userId() },
									size: 40)
						.readSize { size in
							self.avatarSize = size
						}
					}
					
					VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
						HStack(spacing: 0) {
							
							Text(self.conversation.last_message.user.fullName())
								.font(.system(size: 17, weight: .medium))
								.foregroundColor(.primary)
								.lineLimit(1)
								.frame(maxWidth: .infinity, alignment: .leading)
							
							if let dateString = Date.formatConversationLastMessageDate(dateString: self.conversation.last_message.updated_at) {
								Text(dateString)
									.font(.caption)
									.foregroundColor(.secondary)
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
							.foregroundColor(.secondary)
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
				.opacity(self.conversation.unread_count > 0 && !self.conversation.muted ? 1 : 0)
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
		.alert("Leave Group?", isPresented: self.$showLeaveAlert) {
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
			Text("Are you sure you want to proceed?")
		}
	}
}
