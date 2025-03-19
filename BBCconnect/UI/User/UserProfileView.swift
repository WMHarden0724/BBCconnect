//
//  UserProfile.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import AVFoundation
import AlertToast

struct UserProfileView : View {
	
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel = UserViewModel()
	
	@State private var avatar: String?
	@State private var firstName = UserCfg.firstName() ?? ""
	@State private var lastName = UserCfg.lastName() ?? ""
	@State private var showLogoutAlert = false
	@State private var viewSize: CGSize = .zero
	
	@State private var isUpdatingAvatar = false
	@State private var showChangeAvatarAlert = false
	@State private var showTakeImagePicker = false
	@State private var showSelectImagePicker = false
	@State private var showTakeUserToSettingAlert = false
	@State private var noUseImage = UIImage()
	
	private var hasOpenedCameraView: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "profileViewHasOpenedCamera")
		}
	}
	private func setHasOpenedCameraView(_ newValue: Bool) {
		UserDefaults.standard.set(newValue, forKey: "profileViewHasOpenedCamera")
	}
	
	@ViewBuilder
	private func avatarView() -> some View {
		Button(action: {
			self.showChangeAvatarAlert.toggle()
		}) {
			ZStack(alignment: .topLeading) {
				Avatar(type: .userCfg, size: .xl, state: .normal)
				
				Avatar(type: .systemImage("pencil.circle", .primaryContrast, .primaryMain), size: .xs, state: .normal)
					.padding(.leading, 110)
					.padding(.top, 120)
					.shadow(radius: 3)
					.opacity(self.isUpdatingAvatar ? 0 : 1)
				
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: Color.primaryContrast))
					.opacity(self.isUpdatingAvatar ? 1 : 0)
			}
		}
		.animation(.easeInOut, value: self.isUpdatingAvatar)
		.confirmationDialog(Text("New profile photo"), isPresented: self.$showChangeAvatarAlert) {
			Button("Take photo", action: {
				if AVCaptureDevice.authorizationStatus(for: .video) != .authorized && self.hasOpenedCameraView {
					self.showTakeUserToSettingAlert.toggle()
				}
				else {
					setHasOpenedCameraView(true)
					self.showTakeImagePicker.toggle()
				}
			})
			Button("Choose photo from library", action: {
				self.showSelectImagePicker.toggle()
			})
			Spacer()
			Button("Cancel", role: .cancel) {}
		}
		.sheet(isPresented: self.$showTakeImagePicker) {
			ImagePicker(sourceType: .camera, selectedImage: self.$noUseImage) { data in
				if let data = data {
					self.updateAvatar(data: data)
				}
			}
		}
		.sheet(isPresented: self.$showSelectImagePicker) {
			ImagePicker(sourceType: .photoLibrary, selectedImage: self.$noUseImage) { data in
				if let data = data {
					self.updateAvatar(data: data)
				}
			}
		}
		.alert(Text("Camera permission required"), isPresented: $showTakeUserToSettingAlert, actions: {
			Button("Open Settings") {
				if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url)
				}
			}
			Button("Cancel", role: .cancel, action: {})
		}, message: {
			Text("Please open settings and give the BBC Connect permission to use the camera.")
		})
	}
	
	var body: some View {
		VStack(spacing: Dimens.verticalPadding) {
			self.avatarView()
			
			Text("\(self.firstName) \(self.lastName)")
				.font(.largeTitle)
				.foregroundColor(.textPrimary)
				.padding(.top, Dimens.verticalPadding)
			
			Spacer()
			
			// TODO add editable fields for user to modify their profile
			
			BButton(style: .destructive, text: "Log Out") {
				self.showLogoutAlert.toggle()
			}
			.padding(.bottom, Dimens.verticalPadding)
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
			case .avatar:
				self.avatar = value as? String
			case .firstName:
				self.firstName = value as? String ?? ""
			case .lastName:
				self.lastName = value as? String ?? ""
			default:
				break
			}
		})
		.onAppear {
			self.avatar = UserCfg.avatar()
			self.firstName = UserCfg.firstName() ?? ""
			self.lastName = UserCfg.lastName() ?? ""
		}
	}
	
	private func updateAvatar(data: Data) {
		Task {
			await self.viewModel.updateAvatar(data: data)
		}
	}
}
