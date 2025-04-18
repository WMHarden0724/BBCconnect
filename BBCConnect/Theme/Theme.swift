//
//  Theme.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import UIKit
import SwiftUI

public class Theme {
	
	public static func apply() {
		let appearance = UINavigationBarAppearance()
		appearance.configureWithDefaultBackground()
		appearance.backgroundColor = UIColor(Color.background)
		
		// 🛑 Remove bottom line (shadow)
//		appearance.shadowColor = .clear

		// 🎨 Change title font
		appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
		appearance.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]

		let navigationBar = UINavigationBar.appearance()
		navigationBar.tintColor = UIColor(Color.background)
		navigationBar.barTintColor = UIColor(Color.background)
		navigationBar.standardAppearance = appearance
		navigationBar.compactAppearance = appearance
		navigationBar.scrollEdgeAppearance = appearance
		
		/// TabBar
		let standardTabBarAppearance = UITabBarAppearance()
		standardTabBarAppearance.configureWithDefaultBackground()
		standardTabBarAppearance.backgroundColor = UIColor(Color.background)
		standardTabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary)
		standardTabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.primary)]
		standardTabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.secondary)
		standardTabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.secondary)]
		
		let tabBar = UITabBar.appearance()
		tabBar.standardAppearance = standardTabBarAppearance
		tabBar.scrollEdgeAppearance = standardTabBarAppearance
		
		/// Segmented Control
		/// Uses the regular font size
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.primaryMain)
		
		UITableView.appearance().backgroundColor = UIColor.clear
	}
}
