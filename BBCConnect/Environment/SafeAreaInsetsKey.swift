//
//  SafeAreaInsetsKey.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//


import Foundation
import SwiftUI

@available(iOSApplicationExtension, unavailable)
private struct SafeAreaInsetsKey: EnvironmentKey {
	static var defaultValue: EdgeInsets {
		UIApplication.shared.safeAreaInsets
	}
}

@available(iOSApplicationExtension, unavailable)
public extension EnvironmentValues {
	var safeAreaInsets: EdgeInsets {
		self[SafeAreaInsetsKey.self]
	}
}

public extension UIApplication {
	var keyWindow: UIWindow? {
		self.connectedScenes
			.compactMap {
				$0 as? UIWindowScene
			}
			.flatMap {
				$0.windows
			}
			.first {
				$0.isKeyWindow
			}
	}
	
	var safeAreaInsets: EdgeInsets {
		(self.keyWindow?.safeAreaInsets ?? .zero).insets
	}
}

private extension UIEdgeInsets {
	
	var insets: EdgeInsets {
		EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
	}
}
