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
	
	let style: BButtonStyle
	let text: String
	let action: () -> Void
	
	var body: some View {
		Button(action: {
			self.action()
		}) {
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
