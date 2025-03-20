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
	
	var body: some View {
		HStack(alignment: .bottom, spacing: Dimens.horizontalPaddingXsm) {
			if self.isFromYou {
				Spacer()
			}
			
			if self.shouldShowParticipantInfo && !self.isFromYou {
				Avatar(type: .image(self.message.user), size: .xs, state: .normal)
			}
			
			Text(self.message.content)
				.conversationMessageBubbleStyle(isFromYou: self.isFromYou)
			
			if self.shouldShowParticipantInfo && self.isFromYou {
				Avatar(type: .image(self.message.user), size: .xs, state: .normal)
			}
			
			if !self.isFromYou {
				Spacer()
			}
		}
	}
}
