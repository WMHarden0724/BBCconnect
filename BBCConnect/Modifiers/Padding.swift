//
//  Padding.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import SwiftUI

public struct PaddingModifier: ViewModifier {
	
	@State private var orientation = UIDevice.current.orientation
	
	private var viewWidth: CGFloat
	private var maxViewWidth: CGFloat
	private var defaultPadding: CGFloat
	private var ratio: CGFloat?
	
	public init(viewWidth: CGFloat, maxViewWidth: CGFloat, defaultPadding: CGFloat = Dimens.horizontalPadding, ratio: CGFloat? = nil) {
		self.viewWidth = viewWidth
		self.maxViewWidth = maxViewWidth
		self.defaultPadding = defaultPadding
		self.ratio = ratio
	}
	
	private func calculatePadding() -> CGFloat {
		return Self.calculatePadding(orientation: self.orientation, viewWidth: self.viewWidth, maxViewWidth: self.maxViewWidth, defaultPadding: self.defaultPadding, ratio: self.ratio)
	}
	
	public func body(content: Content) -> some View {
		content
			.padding([.leading, .trailing], self.calculatePadding())
			.detectOrientationChanged(self.$orientation)
	}
	
	public static func calculatePadding(orientation: UIDeviceOrientation, viewWidth: CGFloat, maxViewWidth: CGFloat = 600, defaultPadding: CGFloat = Dimens.horizontalPadding, ratio: CGFloat? = nil) -> CGFloat {
		if let ratio = ratio {
			return viewWidth * ratio
		}
		else {
			let maxWidthCalculated = maxViewWidth + (defaultPadding * 2)
			if viewWidth > maxWidthCalculated {
				return ((viewWidth - maxViewWidth) / 2) + defaultPadding
			}
			
			return defaultPadding
		}
	}
}

public extension View {
	
	func applyHorizontalPadding(viewWidth: CGFloat, maxViewWidth: CGFloat = 600, defaultPadding: CGFloat = Dimens.horizontalPadding, ratio: CGFloat? = nil) -> some View {
		modifier(PaddingModifier(viewWidth: viewWidth, maxViewWidth: maxViewWidth, defaultPadding: defaultPadding, ratio: ratio))
	}
}
