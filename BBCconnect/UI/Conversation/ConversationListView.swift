//
//  ConversationListView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/20/25.
//

import SwiftUI
import AlertToast

struct ConversationListView : View {
	
	@StateObject private var viewModel = ConversationsViewModel.shared
	@Binding var selectedConversation: Conversation?
	@Binding var creatingConversation: Bool
	
	@State private var viewSize: CGSize = .zero
	
	@State private var alertToastError: String?
	
	var body: some View {
		ZStack {
			ScrollView {
				LazyVStack(spacing: 0) {
					ForEach(self.viewModel.conversations, id: \.id) { conversation in						
						ConversationItemView(conversation: conversation, onOpen: {
							self.selectedConversation = conversation
						}) {
							self.leaveConversation(conversation)
						}
					}
					
					Spacer(minLength: Dimens.verticalPadding)
				}
			}
			.background(Color.background)
			.refreshable {
				await self.viewModel.fetchConversations()
			}
			
			if self.viewModel.conversations.isEmpty {
				VStack {
					Spacer()
					
					Text("No conversations")
						.font(.headline)
						.foregroundColor(.textPrimary)
						.frame(maxWidth: .infinity)
					
					Spacer()
				}
			}
			
			ProgressView()
				.progressViewStyle(CircularProgressViewStyle(tint: Color.textPrimary))
				.opacity(self.viewModel.loadingState.isLoading ? 1 : 0)
		}
		.readSize { size in
			self.viewSize = size
		}
		.animation(.easeInOut, value: self.viewModel.conversations)
		.animation(.easeInOut, value: self.viewModel.loadingState)
		.toast(isPresenting: Binding(
			get: { self.alertToastError != nil },
			set: { if !$0 { self.alertToastError = nil } }
		), alert: {
			AlertToast(type: .error(Color.errorMain), title: self.alertToastError ?? "")
		}, completion: {
			self.alertToastError = nil
		})
		.backgroundIgnoreSafeArea()
		.onCfgChanged(onChanged: { cfgType, value in
			if cfgType == .sessionToken, UserCfg.isLoggedIn() {
				Task {
					await self.viewModel.fetchConversations()
				}
			}
		})
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Conversations")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
					self.creatingConversation.toggle()
				}) {
					Image(systemName: "square.and.pencil")
						.tint(.actionActive)
						.imageScale(.medium)
				}
			}
		}
		.onCfgChanged(onChanged: { cfgType, value in
			if cfgType == .sessionToken {
				if UserCfg.isLoggedIn() {
					Task {
						await self.viewModel.fetchConversations()
					}
				}
				else {
					self.viewModel.conversations.removeAll()
				}
			}
		})
	}
	
	func leaveConversation(_ conversation: Conversation) {
		Task {
			if let error = await self.viewModel.leaveConversation(conversationId: conversation.id) {
				self.alertToastError = error
			}
		}
	}
}
