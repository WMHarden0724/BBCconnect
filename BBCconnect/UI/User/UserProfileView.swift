//
//  UserProfile.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct UserProfileView : View {
	
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel = UserViewModel()
	
	@State private var firstName = UserCfg.firstName() ?? ""
	@State private var lastName = UserCfg.lastName() ?? ""
	@State private var showLogoutAlert = false
	@State private var viewSize: CGSize = .zero
	
	var body: some View {
		VStack {
			AvatarImageView(style: .large)
			
			Text("\(self.firstName) \(self.lastName)")
				.font(.largeTitle)
				.foregroundColor(.textPrimary)
				.padding(.top, Dimens.vertical)
			
			Spacer()
			
			// TODO add editable fields for user to modify their profile
			
			BButton(style: .destructive, text: "Log Out") {
				self.showLogoutAlert.toggle()
			}
			.padding(.bottom, Dimens.vertical)
		}
		.applyHorizontalPadding(viewWidth: self.viewSize.width)
		.backgroundIgnoreSafeArea()
		.alert("Log Out", isPresented: self.$showLogoutAlert) {
			Button("Cancel", role: .cancel) { }
			Button("Log Out", role: .destructive) {
				UserCfg.logOut()
				self.dismiss()
			}
		} message: {
			Text("Are you sure you want to log out?")
		}
		.readSize { size in
			self.viewSize = size
		}
		.onCfgChanged(onChanged: { cfgType, value in
			switch cfgType {
			case .firstName:
				self.firstName = value as? String ?? ""
			case .lastName:
				self.lastName = value as? String ?? ""
			default:
				break
			}
		})
		.onAppear {
			self.firstName = UserCfg.firstName() ?? ""
			self.lastName = UserCfg.lastName() ?? ""
		}
	}
}
