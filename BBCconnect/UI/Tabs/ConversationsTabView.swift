//
//  ConversationsTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import SwiftUI
import AlertToast

struct ConversationsTabView : View {
	
	@StateObject private var viewModel: ConversationsViewModel
	@State private var conversationToLeave: Conversation?
	@State private var selectedConversation: Conversation?
	@State private var creatingConversation = false
	@State private var viewSize: CGSize = .zero
	
	@State private var alertToastError: String?
	
	init(viewModel: ConversationsViewModel? = nil) {
		_viewModel = StateObject(wrappedValue: viewModel ?? ConversationsViewModel.shared)
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				List {
					ForEach(self.viewModel.conversations, id: \.id) { conversation in
						Button(action: {
							self.selectedConversation = conversation
						}) {
							ConversationItemView(conversation: conversation)
						}
						.listRowBackground(Color.background)
						.swipeActions(edge: .trailing) {
							Button {
								self.conversationToLeave = conversation
							} label: {
								Label("Delete", systemImage: "trash")
							}
							.tint(Color.errorMain)
						}
					}
				}
				.background(Color.backgroundDark)
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
			//			.applyHorizontalPadding(viewWidth: self.viewSize.width)
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
			.backgroundIgnoreSafeArea(color: .backgroundDark)
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
			.sheet(item: self.$selectedConversation, content: { conversation in
				ConversationView(conversation: conversation)
					.interactiveDismissDisabled()
			})
			.sheet(isPresented: self.$creatingConversation) {
				NewConversationView()
					.interactiveDismissDisabled()
			}
			.alert("Leave conversation?",
				   isPresented: Binding(
					get: { self.conversationToLeave != nil },
					set: { if !$0 { self.conversationToLeave = nil } }
				   ),
				   presenting: self.conversationToLeave) { conversation in
				Button("Leave", role: .destructive) {
					self.leaveConversation(conversation)
				}
				Button("Cancel", role: .cancel) { }
			} message: { conversation in
				if conversation.owner_id == UserCfg.userId() {
					Text("Are you sure you want to proceed? Since you own this conversation, ownership will pass to the next available user. If no other users exist, this conversation will be removed")
				}
				else {
					Text("Are you sure you want to proceed?")
				}
			}
		}
	}
	
	func leaveConversation(_ conversation: Conversation) {
		Task {
			if let error = await self.viewModel.leaveConversation(conversationId: conversation.id) {
				self.alertToastError = error
			}
		}
	}
}

struct ConversationsTabView_Previews: PreviewProvider {
	static var previews: some View {
		ConversationsTabView(viewModel: MockConversationsViewModel())
	}
}
