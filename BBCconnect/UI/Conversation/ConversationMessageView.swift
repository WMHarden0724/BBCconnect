//
//  ConversationMessageView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI

struct ConversationMessageView: View {
	
	let message: ConversationMessage
	let isFromYou: Bool
	let shouldShowParticipantInfo: Bool
	let showOwnerName: Bool
	let participantOpacity: Double
	
	init(message: ConversationMessage, isFromYou: Bool, shouldShowParticipantInfo: Bool, showOwnerName: Bool = false, participantOpacity: Double = 1) {
		self.message = message
		self.isFromYou = isFromYou
		self.shouldShowParticipantInfo = shouldShowParticipantInfo
		self.showOwnerName = showOwnerName
		self.participantOpacity = participantOpacity
	}
	
	var body: some View {
		HStack(alignment: .bottom, spacing: 0) {
			if self.isFromYou {
				Spacer()
			}
			
			if self.shouldShowParticipantInfo && !self.isFromYou {
				Avatar(type: .image(self.message.user), size: .xs, state: .normal)
					.opacity(self.participantOpacity)
			}
			
			VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
				if self.showOwnerName {
					Text(self.message.user.first_name)
						.font(.footnote)
						.foregroundColor(.secondary)
						.padding(.leading, Dimens.horizontalPadding)
				}
				
				Text(self.message.content)
					.conversationMessageBubbleStyle(isFromYou: self.isFromYou)
			}
			
			if self.shouldShowParticipantInfo && self.isFromYou {
				Avatar(type: .image(self.message.user), size: .xs, state: .normal)
					.opacity(self.participantOpacity)
			}
			
			if !self.isFromYou {
				Spacer()
			}
		}
	}
}
