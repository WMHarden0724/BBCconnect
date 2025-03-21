//
//  Background.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

public extension View {
	
	func backgroundIgnoreSafeArea(color: Color) -> some View {
		background(
			color.edgesIgnoringSafeArea(.all)
		)
	}
}
