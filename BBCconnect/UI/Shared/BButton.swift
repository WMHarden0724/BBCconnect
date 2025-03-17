//
//  BButton.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

enum BButtonStyle {
	case primary
	case secondary
	
	internal var background: Color {
		switch self {
		case .primary:
			return .primaryMain
		case .secondary:
			return .secondaryMain
		}
	}
	
	internal var foreground: Color {
		switch self {
		case .primary:
			return .primaryContrast
		case .secondary:
			return .secondaryContrast
		}
	}
}

struct BButton : View {
	
	private let style: BButtonStyle
	private let text: String
	private var isLoading: Bool
	private let action: () -> Void
	
	init(
		style: BButtonStyle,
		text: String,
		action: @escaping () -> Void
	) {
		self.style = style
		self.text = text
		self.isLoading = false
		self.action = action
	}
	
	init(
		style: BButtonStyle,
		text: String,
		isLoading: Bool = true,
		action: @escaping () -> Void
	) {
		self.style = style
		self.text = text
		self.action = action
		self.isLoading = isLoading
	}
	
	var body: some View {
		Button(action: {
			self.action()
		}) {
			ZStack {
				Text(self.text)
					.font(.headline)
					.foregroundColor(self.style.foreground)
					.padding()
					.frame(maxWidth: .infinity)
					.opacity(self.isLoading ? 0 : 1)
				
				if self.isLoading {
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: self.style.foreground))
				}
			}
			.background(self.style.background)
			.cornerRadius(12)
		}
		.disabled(self.isLoading)
	}
}

struct BNavigationLink<P> : View where P : Hashable {
	
	let style: BButtonStyle
	let value: P?
	let text: String
	
	var body: some View {
		NavigationLink(value: self.value) {
			Text(self.text)
				.font(.headline)
				.foregroundColor(self.style.foreground)
				.padding()
				.frame(maxWidth: .infinity)
				.background(self.style.background)
				.cornerRadius(12)
		}
	}
}
