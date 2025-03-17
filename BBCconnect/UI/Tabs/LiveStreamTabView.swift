//
//  LiveStreamTabView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct LiveStreamTabView : View {
	
	var body: some View {
		VStack {
			Spacer()
			Image(systemName: "video")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("Live stream stuff here")
				.frame(maxWidth: .infinity)
			Spacer()
		}
		.padding()
		.backgroundIgnoreSafeArea()
	}
}
