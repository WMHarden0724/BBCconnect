//
//  CardView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 4/1/25.
//

import SwiftUI

struct CardView<Content> : View where Content : View {
	
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			self.content
		}
		.background(Color.background)
		.cornerRadius(8)
	}
}
