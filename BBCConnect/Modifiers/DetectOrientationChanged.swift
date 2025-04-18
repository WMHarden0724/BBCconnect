//
//  DetectOrientationChanged.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

struct DetectOrientationChanged: ViewModifier {
	
	@Binding var orientation: UIDeviceOrientation
	
	func body(content: Content) -> some View {
		content
			.onAppear {
				self.orientation = UIDevice.current.orientation
			}
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				self.orientation = UIDevice.current.orientation
			}
	}
}

public extension View {
	func detectOrientationChanged(_ orientation: Binding<UIDeviceOrientation>) -> some View {
		modifier(DetectOrientationChanged(orientation: orientation))
	}
}
