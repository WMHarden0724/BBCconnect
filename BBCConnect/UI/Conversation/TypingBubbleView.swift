//
//  TypingBubbleView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI

struct TypingBubbleView: View {
	
	private let user: User?
	private let shouldShowParticipantInfo: Bool
	@State private var isAnimating = false
	
	init(user: User? = nil, shouldShowParticipantInfo: Bool) {
		self.user = user
		self.shouldShowParticipantInfo = shouldShowParticipantInfo
	}
	
	var body: some View {
		HStack(alignment: .bottom, spacing: Dimens.horizontalPaddingXsm) {
			if let user = self.user, self.shouldShowParticipantInfo {
				Avatar(type: .image(user), size: .xs, state: .normal)
			}
			
			HStack(spacing: 4) {
				Circle().frame(width: 8, height: 8)
					.foregroundColor(.white)
					.opacity(isAnimating ? 1 : 0.3)
					.animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
				
				Circle().frame(width: 8, height: 8)
					.foregroundColor(.white)
					.opacity(isAnimating ? 1 : 0.3)
					.animation(Animation.easeInOut(duration: 0.6).delay(0.2).repeatForever(autoreverses: true), value: isAnimating)
				
				Circle().frame(width: 8, height: 8)
					.foregroundColor(.white)
					.opacity(isAnimating ? 1 : 0.3)
					.animation(Animation.easeInOut(duration: 0.6).delay(0.4).repeatForever(autoreverses: true), value: isAnimating)
			}
			.padding(.vertical, Dimens.verticalPaddingXsm)
			.conversationMessageBubbleStyle(isFromYou: false)
			
			Spacer()
		}
		.onAppear {
			isAnimating = true
		}
	}
}
