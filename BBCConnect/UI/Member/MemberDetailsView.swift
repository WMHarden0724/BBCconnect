//
//  MemberDetails.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/12/25.
//

import SwiftUI
import AlertToast

struct MemberDetailsView : View {
	
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colorScheme

	let user: User
	
	@State private var showDeleteMemberAlert = false
	@State private var isUserListExpanded = false
	@State private var isAddingUsers = false
	@State private var alertToastError: String?
	@State private var viewSize: CGSize = .zero
	
	@State private var isDeleting = false
	@State private var didApprove = false
	@State private var isApproving = false
	
	@ViewBuilder
	private func actionsView() -> some View {
		VStack(spacing: Dimens.verticalPadding) {
			if UserCfg.isAdmin() {
				
				BButton(style: .destructive, text: "Delete Member", isLoading: self.isDeleting) {
					self.showDeleteMemberAlert.toggle()
				}
				
				if self.user.pending && !self.didApprove {
					BButton(style: .primary, text: "Approve Member", isLoading: self.isApproving) {
						self.approveUser()
					}
					.padding(.top, Dimens.verticalPadding)
				}
			}
		}
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: Dimens.verticalPadding) {
					Avatar(type: .image(self.user), size: .custom(100), state: .normal)
					
					Text(self.user.fullName())
					   .foregroundColor(.primary)
					   .font(.largeTitle)
					
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
			.alert("Delete Member?", isPresented: self.$showDeleteMemberAlert) {
				Button("Delete", role: .destructive) {
					self.deleteUser()
				}
				Button("Cancel", role: .cancel) {}
			} message: {
				Text("Are you sure you want to delete this member?")
			}
			.readSize { size in
				self.viewSize = size
			}
			.backgroundIgnoreSafeArea(color: .background)
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
			.toolbarRole(.automatic)

		}
		.tint(.primaryMain)
	}
	
	private func deleteUser() {
		withAnimation {
			self.isDeleting = true
		}
		
		Task {
			let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .deleteUser(self.user.id))
			DispatchQueue.main.async {
				withAnimation {
					self.isDeleting = false
				}
				
				if case .success(_) = result {
					self.dismiss()
				}
				else if case .failure(let aPIError) = result {
					self.alertToastError = aPIError.localizedDescription
				}
			}
		}
	}
	
	private func approveUser() {
		withAnimation {
			self.isApproving = true
		}
		
		Task {
			let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .approveUser(self.user.id))
			DispatchQueue.main.async {
				withAnimation {
					self.isApproving = false
					if case .success(_) = result {
						self.didApprove = true
					}
					else if case .failure(let aPIError) = result {
						self.alertToastError = aPIError.localizedDescription
					}
				}
			}
		}
	}
}
