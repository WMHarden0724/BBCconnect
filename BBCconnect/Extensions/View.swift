//
//  View.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import Foundation
import UIKit
import SwiftUI

extension View {
	func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
									   to: nil, from: nil, for: nil)
	}
	
	@ViewBuilder
	func `if`<Content: View>(_ condition: Bool, apply: (Self) -> Content) -> some View {
		if condition {
			apply(self)
		} else {
			self
		}
	}
}
