//
//  Avatar.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI
import AVFoundation
import AlertToast

enum AvatarStyle {
	case large
	case small
	
	internal var size: CGFloat {
		switch self {
		case .large: return 150
		case .small: return 24
		}
	}
}

struct AvatarImageView : View {
	
	@StateObject private var viewModel = UserAvatarViewModel()
	
	let style: AvatarStyle
	
	@State private var avatar: UIImage?
	
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
	private func avatarImage() -> some View {
		if let avatar = self.avatar {
			Image(uiImage: avatar)
				.resizable()
				.scaledToFill()
				.frame(width: self.style.size, height: self.style.size)
		}
		else {
			Image(systemName: "person.circle.fill")
				.resizable()
				.scaledToFill()
				.tint(.primaryMain)
				.frame(width: self.style.size, height: self.style.size)
		}
	}
	
	var body: some View {
		VStack {
			if self.style == .large {
				Button(action: {
					self.showChangeAvatarAlert.toggle()
				}) {
					ZStack(alignment: .topLeading) {
						self.avatarImage()
							.clipShape(Circle())
							.opacity(self.viewModel.loadingState.isLoading ? 0 : 1)
						
						Image(systemName: "pencil.circle")
							.imageScale(.large)
							.tint(.primaryContrast)
							.background(
								Color.primaryMain
							)
							.clipShape(Circle())
							.padding(.leading, 110)
							.padding(.top, 120)
							.shadow(radius: 3)
							.opacity(self.viewModel.loadingState.isLoading ? 0 : 1)
						
						if self.viewModel.loadingState.isLoading {
							ProgressView()
								.background(
									Color.primaryMain
										.frame(width: 150, height: 150)
										.clipShape(Circle())
								)
						}
					}
				}
				.disabled(self.viewModel.loadingState.isLoading)
			}
			else {
				self.avatarImage()
					.clipShape(Circle())
			}
		}
		.animation(.easeInOut, value: self.viewModel.loadingState)
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
		.onCfgChanged(onChanged: { cfgType, _ in
			if cfgType == .avatar {
				self.loadAvatar()
			}
		})
		.onAppear {
			self.loadAvatar()
		}
	}
	
	private func updateAvatar(data: Data) {
		let base64 = data.base64EncodedString()
		Task {
			await self.viewModel.updateAvatar(avatarBase64: base64)
		}
	}
	
	private func loadAvatar() {
		Task {
			if let avatarBase64 = UserCfg.avatar() {
				let image = self.decodeBase64ToImage(avatarBase64)
				DispatchQueue.main.async {
					withAnimation {
						self.avatar = image
					}
				}
			}
		}
	}
	
	func decodeBase64ToImage(_ base64: String) -> UIImage? {
		guard let data = Data(base64Encoded: base64),
			  let image = UIImage(data: data) else {
			return nil
		}
		return image
	}
}
