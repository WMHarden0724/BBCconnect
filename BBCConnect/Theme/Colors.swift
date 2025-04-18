//
//  Colors.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import UIKit
import SwiftUI

public struct LightColors {
	
	static let avatar = UIColor.systemGray2
	static let actionActive = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.5607843137254902)
	static let actionDisabled = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.2)
	static let backgroundLight = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
	static let backgroundDark = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
	static let background = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
	static let divider = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.00)
	static let errorContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let errorMain = UIColor.systemRed
	static let messageBubbleYou = UIColor(red: 133/255.0, green: 167/255.0, blue: 166/255.0, alpha: 1.0)
	static let messageBubbleOther = UIColor.systemGray4
	static let paper = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let primaryContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let primaryMain = UIColor(red: 133/255.0, green: 167/255.0, blue: 166/255.0, alpha: 1.0)
	static let primaryLight = UIColor(red: 179/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
	static let primaryDark = UIColor(red: 94/255.0, green: 120/255.0, blue: 119/255.0, alpha: 1.0)
	static let secondaryContrast = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let secondaryMain = UIColor(red: 244/255.0, green: 237/255.0, blue: 229/255.0, alpha: 1.0)
	static let secondaryLight = UIColor(red: 244/255.0, green: 237/255.0, blue: 229/255.0, alpha: 1.0)
	static let secondaryDark = UIColor(red: 244/255.0, green: 237/255.0, blue: 229/255.0, alpha: 1.0)
}

public struct DarkColors {
	
	static let avatar = UIColor.systemGray2
	static let actionActive = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.5607843137254902)
	static let actionDisabled = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.2)
	static let backgroundLight = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
	static let backgroundDark = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1.0)
	static let background = UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1.0)
	static let divider = UIColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1.00)
	static let errorContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let errorMain = UIColor.systemRed
	static let messageBubbleYou = UIColor(red: 133/255.0, green: 167/255.0, blue: 166/255.0, alpha: 1.0)
	static let messageBubbleOther = UIColor.systemGray5
	static let paper = UIColor(red: 0.141, green: 0.153, blue: 0.161, alpha: 1)
	static let primaryContrast = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let primaryMain = UIColor(red: 133/255.0, green: 167/255.0, blue: 166/255.0, alpha: 1.0)
	static let primaryLight = UIColor(red: 179/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
	static let primaryDark = UIColor(red: 94/255.0, green: 120/255.0, blue: 119/255.0, alpha: 1.0)
	static let secondaryContrast = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let secondaryMain = UIColor(red: 244/255.0, green: 237/255.0, blue: 229/255.0, alpha: 1.0)
	static let secondaryLight = UIColor(red: 244/255.0, green: 237/255.0, blue: 229/255.0, alpha: 1.0)
	static let secondaryDark = UIColor(red: 244/255.0, green: 237/255.0, blue: 229/255.0, alpha: 1.0)
}


public enum ColorType {
	case avatar
	case actionDisabled
	case actionActive
	case backgroundLight
	case backgroundDark
	case background
	case divider
	case errorContrast
	case errorMain
	case messageBubbleYou
	case messageBubbleOther
	case paper
	case primaryContrast
	case primaryMain
	case primaryLight
	case primaryDark
	case secondaryContrast
	case secondaryMain
	case secondaryLight
	case secondaryDark
	
	public static func color(type: ColorType) -> UIColor {
		let color = UIColor { (traitCollection: UITraitCollection) -> UIColor in
			return ColorType.color(type: type, isDarkMode: traitCollection.userInterfaceStyle == .dark)
		}
		return color
	}
	
	/// Retrieve a color based on the `WFThemeColorType` from our theme delegate, forcing whether dark mode or not
	public static func color(type: ColorType, isDarkMode: Bool) -> UIColor {
		switch type {
		case .avatar:
			return isDarkMode ? DarkColors.avatar : LightColors.avatar
		case .actionActive:
			return isDarkMode ? DarkColors.actionActive : LightColors.actionActive
		case .actionDisabled:
			return isDarkMode ? DarkColors.actionDisabled : LightColors.actionDisabled
		case .backgroundLight:
			return isDarkMode ? DarkColors.backgroundLight : LightColors.backgroundLight
		case .backgroundDark:
			return isDarkMode ? DarkColors.backgroundDark : LightColors.backgroundDark
		case .background:
			return isDarkMode ? DarkColors.background : LightColors.background
		case .divider:
			return isDarkMode ? DarkColors.divider : LightColors.divider
		case .errorContrast:
			return isDarkMode ? DarkColors.errorContrast : LightColors.errorContrast
		case .errorMain:
			return isDarkMode ? DarkColors.errorMain : LightColors.errorMain
		case .messageBubbleYou:
			return isDarkMode ? DarkColors.messageBubbleYou : LightColors.messageBubbleYou
		case .messageBubbleOther:
			return isDarkMode ? DarkColors.messageBubbleOther : LightColors.messageBubbleOther
		case .paper:
			return isDarkMode ? DarkColors.paper : LightColors.paper
		case .primaryContrast:
			return isDarkMode ? DarkColors.primaryContrast : LightColors.primaryContrast
		case .primaryMain:
			return isDarkMode ? DarkColors.primaryMain : LightColors.primaryMain
		case .primaryLight:
			return isDarkMode ? DarkColors.primaryLight : LightColors.primaryLight
		case .primaryDark:
			return isDarkMode ? DarkColors.primaryDark : LightColors.primaryDark
		case .secondaryContrast:
			return isDarkMode ? DarkColors.secondaryContrast : LightColors.secondaryContrast
		case .secondaryMain:
			return isDarkMode ? DarkColors.secondaryMain : LightColors.secondaryMain
		case .secondaryLight:
			return isDarkMode ? DarkColors.secondaryLight : LightColors.secondaryLight
		case .secondaryDark:
			return isDarkMode ? DarkColors.secondaryDark : LightColors.secondaryDark
		}
	}
}

public extension Color {
	static var avatar: Color {
		get {
			return Color(ColorType.color(type: .avatar))
		}
	}
	static var actionActive: Color {
		get {
			return Color(ColorType.color(type: .actionActive))
		}
	}
	static var actionDisabled: Color {
		get {
			return Color(ColorType.color(type: .actionDisabled))
		}
	}
	static var backgroundLight: Color {
		get {
			return Color(ColorType.color(type: .backgroundLight))
		}
	}
	static var backgroundDark: Color {
		get {
			return Color(ColorType.color(type: .backgroundDark))
		}
	}
	static var background: Color {
		get {
			return Color(ColorType.color(type: .background))
		}
	}
	static var divider: Color {
		get {
			return Color(ColorType.color(type: .divider))
		}
	}
	static var errorContrast: Color {
		get {
			return Color(ColorType.color(type: .errorContrast))
		}
	}
	static var errorMain: Color {
		get {
			return Color(ColorType.color(type: .errorMain))
		}
	}
	static var messageBubbleYou: Color {
		get {
			return Color(ColorType.color(type: .messageBubbleYou))
		}
	}
	static var messageBubbleOther: Color {
		get {
			return Color(ColorType.color(type: .messageBubbleOther))
		}
	}
	static var paper: Color {
		get {
			return Color(ColorType.color(type: .paper))
		}
	}
	static var primaryContrast: Color {
		get {
			return Color(ColorType.color(type: .primaryContrast))
		}
	}
	static var primaryMain: Color {
		get {
			return Color(ColorType.color(type: .primaryMain))
		}
	}
	static var primaryLight: Color {
		get {
			return Color(ColorType.color(type: .primaryLight))
		}
	}
	static var primaryDark: Color {
		get {
			return Color(ColorType.color(type: .primaryDark))
		}
	}
	static var secondaryContrast: Color {
		get {
			return Color(ColorType.color(type: .secondaryContrast))
		}
	}
	static var secondaryMain: Color {
		get {
			return Color(ColorType.color(type: .secondaryMain))
		}
	}
	static var secondaryLight: Color {
		get {
			return Color(ColorType.color(type: .secondaryLight))
		}
	}
	static var secondaryDark: Color {
		get {
			return Color(ColorType.color(type: .secondaryDark))
		}
	}
}

// Helper to initialize Color with hex
extension Color {
	init(hex: String) {
		let scanner = Scanner(string: hex)
		scanner.currentIndex = scanner.string.startIndex
		var rgbValue: UInt64 = 0
		scanner.scanHexInt64(&rgbValue)
		
		let red = Double((rgbValue >> 16) & 0xFF) / 255.0
		let green = Double((rgbValue >> 8) & 0xFF) / 255.0
		let blue = Double(rgbValue & 0xFF) / 255.0
		
		self.init(red: red, green: green, blue: blue)
	}
}
