//
//  ConversationMessageView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI

struct ConversationMessageView: View {
	
	let message: ConversationMessage
	
	var body: some View {
		HStack(alignment: .bottom, spacing: Dimens.horizontalPaddingXsm) {
			if self.message.user.id == UserCfg.userId() {
				Spacer()
			}
			
			if self.message.user.id != UserCfg.userId() {
				Avatar(type: .image(self.message.user), size: .xs, state: .normal)
			}
			
			Text(self.message.content)
				.conversationMessageBubbleStyle(isFromYou: self.message.user.id == UserCfg.userId())
			
			if self.message.user.id == UserCfg.userId() {
				Avatar(type: .image(self.message.user), size: .xs, state: .normal)
			}
			
			if self.message.user.id != UserCfg.userId() {
				Spacer()
			}
		}
	}
}
