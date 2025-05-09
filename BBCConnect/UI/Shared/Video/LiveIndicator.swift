//
//  LiveIndicator.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/9/25.
//

import SwiftUI

struct LiveIndicator: View {
	
	@State private var isVisible = true
	let isFullScreen: Bool

	var body: some View {
		HStack {
			Circle()
				.fill(Color.red)
				.frame(width: 12, height: 12)
				.opacity(isVisible ? 1 : 0.2)
				.animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isVisible)
				.onAppear {
					isVisible.toggle()
				}
			
			Text("LIVE")
				.foregroundStyle(.red)
				.font(.headline)
				.fontWeight(.bold)
				.foregroundColor(.red)
		}
		.padding(10)
		.background(Color.black.opacity(0.7))
		.cornerRadius(8)
		.padding(.leading, isFullScreen ? 10 : 10)
		.padding(.top, isFullScreen ? 60 : 10)
	}
}
