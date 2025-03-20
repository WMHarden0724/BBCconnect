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
	
	static let actionActive = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.5607843137254902)
	static let actionDisabled = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.2)
	static let backgroundDark = UIColor(red: 0.941, green: 0.945, blue: 0.953, alpha: 1)
	static let background = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let divider = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.12156862745098039)
	static let errorContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let errorMain = UIColor(red: 0.827, green: 0.184, blue: 0.184, alpha: 1)
	static let errorLight = UIColor(red: 0.898, green: 0.451, blue: 0.451, alpha: 1)
	static let errorDark = UIColor(red: 0.718, green: 0.110, blue: 0.110, alpha: 1)
	static let paper = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let primaryContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let primaryMain = UIColor(red: 0.098, green: 0.110, blue: 0.118, alpha: 1)
	static let primaryLight = UIColor(red: 0.180, green: 0.192, blue: 0.200, alpha: 1)
	static let primaryDark = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let secondaryContrast = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let secondaryMain = UIColor(red: 0.882, green: 0.886, blue: 0.898, alpha: 1)
	static let secondaryLight = UIColor(red: 0.941, green: 0.945, blue: 0.953, alpha: 1)
	static let secondaryDark = UIColor(red: 0.773, green: 0.776, blue: 0.788, alpha: 1)
	static let textDisabled = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.2)
	static let textPrimary = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let textSecondary = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.5019607843137254)
}

public struct DarkColors {
	
	static let actionActive = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.5607843137254902)
	static let actionDisabled = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.2)
	static let backgroundDark = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let background = UIColor(red: 0.098, green: 0.110, blue: 0.118, alpha: 1)
	static let divider = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.12156862745098039)
	static let errorContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let errorMain = UIColor(red: 0.937, green: 0.325, blue: 0.314, alpha: 1)
	static let errorLight = UIColor(red: 0.937, green: 0.604, blue: 0.604, alpha: 1)
	static let errorDark = UIColor(red: 0.776, green: 0.157, blue: 0.157, alpha: 1)
	static let paper = UIColor(red: 0.141, green: 0.153, blue: 0.161, alpha: 1)
	static let primaryContrast = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)
	static let primaryMain = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let primaryLight = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let primaryDark = UIColor(red: 0.941, green: 0.945, blue: 0.953, alpha: 1)
	static let secondaryContrast = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let secondaryMain = UIColor(red: 0.271, green: 0.278, blue: 0.286, alpha: 1)
	static let secondaryLight = UIColor(red: 0.361, green: 0.373, blue: 0.380, alpha: 1)
	static let secondaryDark = UIColor(red: 0.180, green: 0.192, blue: 0.200, alpha: 1)
	static let textDisabled = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.2)
	static let textPrimary = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
	static let textSecondary = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.5019607843137254)
}


public enum ColorType {
	case actionDisabled
	case actionActive
	case backgroundDark
	case background
	case divider
	case errorContrast
	case errorMain
	case errorLight
	case errorDark
	case paper
	case primaryContrast
	case primaryMain
	case primaryLight
	case primaryDark
	case secondaryContrast
	case secondaryMain
	case secondaryLight
	case secondaryDark
	case textDisabled
	case textPrimary
	case textSecondary
	
	public static func color(type: ColorType) -> UIColor {
		let color = UIColor { (traitCollection: UITraitCollection) -> UIColor in
			return ColorType.color(type: type, isDarkMode: traitCollection.userInterfaceStyle == .dark)
		}
		return color
	}
	
	/// Retrieve a color based on the `WFThemeColorType` from our theme delegate, forcing whether dark mode or not
	public static func color(type: ColorType, isDarkMode: Bool) -> UIColor {
		switch type {
		case .actionActive:
			return isDarkMode ? DarkColors.actionActive : LightColors.actionActive
		case .actionDisabled:
			return isDarkMode ? DarkColors.actionDisabled : LightColors.actionDisabled
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
		case .errorLight:
			return isDarkMode ? DarkColors.errorLight : LightColors.errorLight
		case .errorDark:
			return isDarkMode ? DarkColors.errorDark : LightColors.errorDark
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
		case .textDisabled:
			return isDarkMode ? DarkColors.textDisabled : LightColors.textDisabled
		case .textPrimary:
			return isDarkMode ? DarkColors.textPrimary : LightColors.textPrimary
		case .textSecondary:
			return isDarkMode ? DarkColors.textSecondary : LightColors.textSecondary
		}
	}
}

public extension Color {
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
	static var errorLight: Color {
		get {
			return Color(ColorType.color(type: .errorLight))
		}
	}
	static var errorDark: Color {
		get {
			return Color(ColorType.color(type: .errorDark))
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
	static var textDisabled: Color {
		get {
			return Color(ColorType.color(type: .textDisabled))
		}
	}
	static var textPrimary: Color {
		get {
			return Color(ColorType.color(type: .textPrimary))
		}
	}
	static var textSecondary: Color {
		get {
			return Color(ColorType.color(type: .textSecondary))
		}
	}
}
