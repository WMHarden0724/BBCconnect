//
//  ConversationItemView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI

struct ConversationItemView : View {
	
	let conversation: Conversation
	
	var body: some View {
		HStack(spacing: Dimens.horizontalPadding) {
			AvatarGroup(items: self.conversation.users.map { AvatarType.image($0) },
						size: .md,
						state: conversation.unread_count > 0 ? .unread : .normal)
			
			VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
				HStack(spacing: 0) {
					
					Text(self.conversation.last_message.user.fullName())
						.font(.headline)
						.foregroundColor(.textPrimary)
						.lineLimit(1)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					if let dateString = Date.formatConversationMessageDate(dateString: self.conversation.last_message.updated_at) {
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
			}
		}
		.padding(.vertical, Dimens.verticalPaddingXsm)
	}
}
