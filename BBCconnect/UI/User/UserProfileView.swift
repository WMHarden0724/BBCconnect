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
	@State private var email = UserCfg.email() ?? ""
	@State private var firstName = UserCfg.firstName() ?? ""
	@State private var lastName = UserCfg.lastName() ?? ""
	@State private var showLogoutAlert = false
	@State private var viewSize: CGSize = .zero
	
	@State private var isEditing = false
	@State private var isUpdatingAvatar = false
	@State private var showChangeAvatarAlert = false
	@State private var showTakeImagePicker = false
	@State private var showSelectImagePicker = false
	@State private var showTakeUserToSettingAlert = false
	@State private var noUseImage = UIImage()
	
	@State private var alertToastError: String?
	@FocusState private var focusedField: Field?
	
	private var hasOpenedCameraView: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "profileViewHasOpenedCamera")
		}
	}
	private func setHasOpenedCameraView(_ newValue: Bool) {
		UserDefaults.standard.set(newValue, forKey: "profileViewHasOpenedCamera")
	}
	
	enum Field {
		case firstName, lastName
	}
	
	@ViewBuilder
	private func avatarView() -> some View {
		Button(action: {
			self.showChangeAvatarAlert.toggle()
		}) {
			ZStack(alignment: .topLeading) {
				Avatar(type: .userCfg, size: .lg, state: .normal)
				
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: Color.primaryContrast))
					.opacity(self.isUpdatingAvatar ? 1 : 0)
			}
		}
		.buttonStyle(.plain)
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
					self.updateUser(data: data, includeOtherInfo: false)
				}
			}
		}
		.sheet(isPresented: self.$showSelectImagePicker) {
			ImagePicker(sourceType: .photoLibrary, selectedImage: self.$noUseImage) { data in
				if let data = data {
					self.updateUser(data: data, includeOtherInfo: false)
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
	
	@ViewBuilder
	private func nameFieldsView() -> some View {
		VStack(spacing: Dimens.verticalPaddingXxsm) {
			if self.isEditing {
				TextField("First Name", text: self.$firstName)
					.foregroundColor(.primary)
					.textFieldStyle(PlainTextFieldStyle())
					.textInputAutocapitalization(.words)
					.focused(self.$focusedField, equals: .firstName)
					.submitLabel(.done)
					.padding(.horizontal, 12)
					.padding(.vertical, 10)
					.foregroundColor(.primary)
					.overlay(
						Capsule()
							.stroke(Color.divider, lineWidth: 1)
					)
					.onSubmit {
						self.focusedField = nil
					}
				
				TextField("Last Name", text: self.$lastName)
					.foregroundColor(.primary)
					.textFieldStyle(PlainTextFieldStyle())
					.textInputAutocapitalization(.words)
					.focused(self.$focusedField, equals: .lastName)
					.submitLabel(.done)
					.padding(.horizontal, 12)
					.padding(.vertical, 10)
					.foregroundColor(.primary)
					.overlay(
						Capsule()
							.stroke(Color.divider, lineWidth: 1)
					)
					.onSubmit {
						self.focusedField = nil
					}
			}
			else {
				Text("\(self.firstName) \(self.lastName)")
					.font(.system(size: 17, weight: .medium))
					.foregroundColor(.primary)
					.frame(maxWidth: .infinity, alignment: .leading)
				
				Text(self.email)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: Dimens.verticalPadding) {
				HStack(alignment: self.isEditing ? .top : .center, spacing: Dimens.horizontalPadding) {
					self.avatarView()
					
					self.nameFieldsView()
				}
				.padding(.horizontal, Dimens.horizontalPaddingMd)
				.padding(.vertical, Dimens.verticalPaddingMd)
				.background(Color.background)
				.cornerRadius(8)
				
				BButton(style: .primary, text: "Log Out") {
					self.showLogoutAlert.toggle()
				}
				
				Spacer()
				
				// TODO add editable fields for user to modify their profile
				
			}
			.padding(.top, Dimens.verticalPadding)
			.applyHorizontalPadding(viewWidth: self.viewSize.width)
		}
		.backgroundIgnoreSafeArea(color: .backgroundDark)
		.toast(isPresenting: Binding(
			get: { self.alertToastError != nil },
			set: { if !$0 { self.alertToastError = nil } }
		), duration: 5, offsetY: 60, alert: {
			AlertToast(displayMode: .hud, type: .error(Color.errorMain), title: self.alertToastError ?? "")
		}, completion: {
			self.alertToastError = nil
		})
		.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
		.toolbarRole(.editor)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
					withAnimation {
						if self.isEditing {
							self.updateUser()
						}
						
						self.isEditing.toggle()
					}
				}) {
					Text(self.isEditing ? "Done" : "Edit")
						.foregroundStyle(.blue)
						.font(.system(size: 17, weight: .medium))
				}
			}
		}
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
			case .email:
				self.email = value as? String ?? ""
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
			self.email = UserCfg.email() ?? ""
			self.firstName = UserCfg.firstName() ?? ""
			self.lastName = UserCfg.lastName() ?? ""
		}
	}
	
	private func updateUser(data: Data? = nil, includeOtherInfo: Bool = true) {
		Task {
			let result = await self.viewModel.updateUserProfile(firstName: includeOtherInfo ? self.firstName : nil,
																lastName: includeOtherInfo ? self.lastName : nil,
																avatar: data)
			DispatchQueue.main.async {
				if let error = result.1 {
					self.alertToastError = error
				}
			}
		}
	}
}
