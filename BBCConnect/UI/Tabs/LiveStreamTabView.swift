//
//  LiveStreamTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct LiveStreamTabView : View {
	
	var body: some View {
		VStack(spacing: Dimens.verticalPadding) {
			Spacer()
			Text("Coming Soon...")
				.frame(maxWidth: .infinity)
			Spacer()
		}
		.padding()
		.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
		.toolbarRole(.editor)
		.backgroundIgnoreSafeArea(color: .background)
	}
}
