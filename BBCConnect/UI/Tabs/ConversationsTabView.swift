//
//  ConversationsTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import AlertToast

struct ConversationsTabView : View {
	
	@Environment(\.horizontalSizeClass) var sizeClass // Detects device type
	
	@State private var selectedConversation: Conversation?
	@State private var creatingConversation = false
	
	var body: some View {
		Group {
//			if self.sizeClass == .compact {
				NavigationStack {
					ConversationListView(selectedConversation: self.$selectedConversation,
										 creatingConversation: self.$creatingConversation)
					.navigationDestination(item: self.$selectedConversation) { conversation in
						ConversationView(conversation: conversation)
					}
				}
				.tint(.primaryMain)
//			}
//			else {
//				NavigationSplitView {
//					ConversationListView(selectedConversation: self.$selectedConversation,
//										 creatingConversation: self.$creatingConversation)
//				} detail: {
//					if let conversation = self.selectedConversation {
//						ConversationDetailView(conversation: conversation)
//					}
//					else {
//						Text("Select a conversation")
//							.foregroundColor(.textSecondary)
//							.frame(maxWidth: .infinity, maxHeight: .infinity)
//					}
//				}
//			}
		}
		.sheet(isPresented: self.$creatingConversation) {
			NewConversationView { conversation in
				self.selectedConversation = conversation
			}.interactiveDismissDisabled()
		}
	}
}
