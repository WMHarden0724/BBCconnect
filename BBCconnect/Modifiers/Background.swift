//
//  Background.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

public extension View {
	
	func backgroundIgnoreSafeArea(color: Color = .background) -> some View {
		background(
			color.edgesIgnoringSafeArea(.all)
		)
	}
}
