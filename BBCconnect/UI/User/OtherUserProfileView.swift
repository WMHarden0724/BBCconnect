//
//  OtherUserProfileView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/31/25.
//

import SwiftUI

struct OtherUserProfileView: View {
	
	let user: User
	
	@State private var viewSize: CGSize = .zero
	
	@ViewBuilder
	private func nameFieldsView() -> some View {
		VStack(spacing: Dimens.verticalPaddingXsm) {
			Text(self.user.fullName(includeRoleIfAdmin: true))
				.font(.system(size: 20, weight: .medium))
				.foregroundColor(.primary)
				.frame(maxWidth: .infinity, alignment: .center)
			
			Text(self.user.email)
				.font(.subheadline)
				.foregroundColor(.secondary)
				.frame(maxWidth: .infinity, alignment: .center)
		}
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: Dimens.verticalPadding) {
				Avatar(type: .image(self.user), size: .xxl, state: .normal)
				
				self.nameFieldsView()
					.padding(.horizontal, Dimens.horizontalPaddingMd)
					.padding(.vertical, Dimens.verticalPaddingMd)
				
				Spacer()
				
				// TODO: other fields
				
			}
			.padding(.top, Dimens.verticalPadding)
			.applyHorizontalPadding(viewWidth: self.viewSize.width)
		}
		.backgroundIgnoreSafeArea(color: .backgroundDark)
		.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
		.toolbarRole(.editor)
		.readSize { size in
			self.viewSize = size
		}
	}
}
