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
	@Environment(\.colorScheme) var colorScheme

	@ObservedObject var viewModel: ConversationViewModel
	var onLeftConversation: () -> Void
	
	@State private var showLeaveConversationAlert = false
	@State private var isUserListExpanded = false
	@State private var isAddingUsers = false
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
	
	private var userCountString: String {
		let count = self.viewModel.conversation.users.filter({ $0.id != UserCfg.userId() }).count
		if count > 1 {
			return "\(count) People"
		}
		
		return "1 Person"
	}
	
	@ViewBuilder
	private func usersList() -> some View {
		CardView {
			
			Button(action: {
				withAnimation {
					self.isUserListExpanded.toggle()
				}
			}) {
				HStack(alignment: .center, spacing: Dimens.horizontalPadding) {
					
					AvatarGroupInline(users: self.viewModel.conversation.users.filter{ $0.id != UserCfg.userId() },
									  size: 40, strokeColor: .primaryMain)
					
					VStack(alignment: .leading, spacing: Dimens.verticalPaddingXxsm) {
						Text(self.userCountString)
							.font(.system(size: 17, weight: .medium))
							.foregroundColor(.primary)
							.lineLimit(1)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						Text(self.viewModel.conversation.users.filter({ $0.id != UserCfg.userId() }).map({ $0.first_name }).joined(separator: ", "))
							.font(.subheadline)
							.foregroundColor(.secondary)
							.lineLimit(2)
							.truncationMode(.tail)
							.multilineTextAlignment(.leading)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					
					Image(systemName: "arrow.forward.circle")
						.imageScale(.medium)
						.tint(.actionActive)
						.rotationEffect(self.isUserListExpanded ? Angle(degrees: 90) : Angle(degrees: 0))
				}
				.padding(.horizontal, Dimens.horizontalPadding)
				.padding(.vertical, Dimens.verticalPadding)
			}
			.buttonStyle(.plain)
			
			if self.isUserListExpanded {
				ForEach(self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() }, id: \.id) { user in
					Divider().foregroundColor(.divider)
					
					NavigationLink(destination: OtherUserProfileView(user: user)) {
						HStack(alignment: .center, spacing: Dimens.horizontalPadding) {
							Avatar(type: .image(user), size: .custom(40), state: .normal)
							
							Text(user.fullName())
								.font(.system(size: 17, weight: .medium))
								.foregroundColor(.primary)
								.lineLimit(1)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						.padding(.horizontal, Dimens.horizontalPaddingMd)
						.padding(.vertical, Dimens.verticalPaddingMd)
					}
				}
				
				Divider().foregroundColor(.divider)
				
				Button(action: {
					self.isAddingUsers.toggle()
				}) {
					HStack(alignment: .center, spacing: Dimens.horizontalPadding) {
						Avatar(type: .systemImage("plus", .primaryMain, .backgroundDark),
							   size: .custom(40),
							   state: .normal)
						
						Text("Add User")
							.font(.system(size: 17, weight: .medium))
							.foregroundColor(.primary)
							.lineLimit(1)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					.padding(.horizontal, Dimens.horizontalPaddingMd)
					.padding(.vertical, Dimens.verticalPaddingMd)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	@ViewBuilder
	private func actionsView() -> some View {
		VStack(spacing: Dimens.verticalPadding) {
			CardView {
				HStack(alignment: .center, spacing: Dimens.horizontalPadding) {
					Toggle("Hide Alerts", isOn: self.$viewModel.muted)
						.font(.system(size: 17, weight: .regular))
						.foregroundColor(.primary)
				}
				.padding(.horizontal, Dimens.horizontalPaddingMd)
				.padding(.vertical, Dimens.verticalPaddingMd)
				.frame(minHeight: Dimens.minListItemHeight)
			}
			
			CardView {
				Button(action: {
					self.showLeaveConversationAlert.toggle()
				}) {
					Text("Leave Conversation")
						.font(.system(size: 17, weight: .regular))
						.foregroundColor(.primary)
						.lineLimit(1)
						.padding(.horizontal, Dimens.horizontalPaddingMd)
						.padding(.vertical, Dimens.verticalPaddingMd)
						.frame(maxWidth: .infinity, minHeight: Dimens.minListItemHeight, alignment: .leading)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: Dimens.verticalPadding) {
					let users = self.viewModel.conversation.users.filter { $0.id != UserCfg.userId() }
					if users.count == 1 {
						Avatar(type: .image(self.viewModel.conversation.users[0]), size: .custom(100), state: .normal)
					}
					else {
						AvatarGroup(users: users,
									width: 200,
									height: 150,
									includeBackground: false)
					}
					
					VStack {
						Text(self.usersTitle)
							.foregroundColor(.primary)
							.font(.largeTitle)
						
						if let timestamp = self.viewModel.conversation.createdAtTimestamp(includeDow: true) {
							Text(timestamp)
								.font(.caption)
								.foregroundColor(.secondary)
						}
					}
					
					self.usersList()
						.padding(.top, Dimens.verticalPaddingSm)
					
					self.actionsView()
				}
				.applyHorizontalPadding(viewWidth: self.viewSize.width)
				.padding(.vertical, Dimens.verticalPadding)
			}
			.toast(isPresenting: Binding(
				get: { self.alertToastError != nil },
				set: { if !$0 { self.alertToastError = nil } }
			), duration: 5, offsetY: 60, alert: {
				AlertToast(displayMode: .hud, type: .error(Color.errorMain), title: self.alertToastError ?? "")
			}, completion: {
				self.alertToastError = nil
			})
			.sheet(isPresented: self.$isAddingUsers) {
				AddUsersToConversationView(viewModel: self.viewModel)
			}
			.alert("Leave Group?", isPresented: self.$showLeaveConversationAlert) {
				Button("Leave", role: .destructive) {
					self.leaveConversation()
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				Text("Are you sure you want to proceed?")
			}
			.onAppear {
				self.viewModel.fetchConversation()
			}
			.readSize { size in
				self.viewSize = size
			}
			.backgroundIgnoreSafeArea(color: .background)
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.automatic)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						self.dismiss()
					}) {
						Text("Done")
							.foregroundColor(.primaryMain)
							.font(.system(size: 17, weight: .medium))
					}
				}
			}
		}
		.tint(.primaryMain)
	}
	
	private func leaveConversation() {
		Task {
			let result = await self.viewModel.leaveConversation()
			DispatchQueue.main.async {
				if result.0 {
					self.onLeftConversation()
					self.dismiss()
				}
				else {
					self.alertToastError = result.1
				}
			}
		}
	}
}
