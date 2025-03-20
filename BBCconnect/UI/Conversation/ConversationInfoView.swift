//
//  ConversationInfoView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/20/25.
//

import SwiftUI
import AlertToast

struct ConversationInfoView : View {
	
	@Environment(\.dismiss) var dismiss
	@ObservedObject var viewModel: ConversationViewModel
	var onLeftConversation: () -> Void
	
	@State private var showLeaveConversationAlert = false
	@State private var alertToastError: String?
	@State private var viewSize: CGSize = .zero
	
	private var usersTitle: String {
		let users = self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() }
		if users.isEmpty {
			return "Yourself"
		}
		else if users.count == 1 {
			return users[0].fullName()
		}
		else if users.count > 2 {
			return "\(users[0].first_name) and \(users.count - 1) others"
		}
		else {
			return "\(users[0].first_name) and \(users[1].first_name)"
		}
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack {
					if self.viewModel.conversation.users.count == 1 {
						Avatar(type: .image(self.viewModel.conversation.users[0]), size: .custom(100), state: .normal)
					}
					else {
						AvatarGroup(users: self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() },
									size: 100,
									includeBackground: false)
					}
					
					Text(self.usersTitle)
						.foregroundColor(.textPrimary)
						.font(.largeTitle)
				}
				.applyHorizontalPadding(viewWidth: self.viewSize.width)
				.padding(.top, Dimens.verticalPadding)
			}
			.toast(isPresenting: Binding(
				get: { self.alertToastError != nil },
				set: { if !$0 { self.alertToastError = nil } }
			), alert: {
				AlertToast(type: .error(Color.errorMain), title: self.alertToastError ?? "")
			}, completion: {
				self.alertToastError = nil
			})
			.alert("Leave conversation?", isPresented: self.$showLeaveConversationAlert) {
				Button("Leave", role: .destructive) {
					self.leaveConversation()
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				if self.viewModel.conversation.owner_id == UserCfg.userId() {
					Text("Are you sure you want to proceed? Since you own this conversation, ownership will pass to the next available user. If no other users exist, this conversation will be removed")
				}
				else {
					Text("Are you sure you want to proceed?")
				}
			}
			.readSize { size in
				self.viewSize = size
			}
			.backgroundIgnoreSafeArea()
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.hidden, for: .navigationBar)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						self.dismiss()
					}) {
						Text("Done")
							.foregroundStyle(.blue)
							.font(.headline)
					}
				}
			}
		}
	}
	
	private func leaveConversation() {
		Task {
			let result = await self.viewModel.leaveConversation()
			DispatchQueue.main.async {
				if result.0 {
					self.dismiss()
				}
				else {
					self.alertToastError = result.1
				}
			}
		}
	}
}
