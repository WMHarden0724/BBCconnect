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

		// 🔙 Remove back button text (invisible title)
		let backButtonAppearance = UIBarButtonItemAppearance()
		backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
		appearance.backButtonAppearance = backButtonAppearance

		// 🖼️ Set custom back button image
		let backImage = UIImage(named: "Icon-Back")?.withRenderingMode(.alwaysOriginal)
		appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

		let navigationBar = UINavigationBar.appearance()
		navigationBar.standardAppearance = appearance
		navigationBar.scrollEdgeAppearance = appearance
		
		/// TabBar
		let standardTabBarAppearance = UITabBarAppearance()
		standardTabBarAppearance.configureWithDefaultBackground()
		standardTabBarAppearance.backgroundColor = UIColor(Color.background)
		standardTabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryMain)
		standardTabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.primaryMain)]
		standardTabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
		standardTabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.textSecondary)]
		
		let tabBar = UITabBar.appearance()
		tabBar.standardAppearance = standardTabBarAppearance
		tabBar.scrollEdgeAppearance = standardTabBarAppearance
		
		/// Segmented Control
		/// Uses the regular font size
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.primaryMain)
		
		UITableView.appearance().backgroundColor = UIColor.clear
	}
}
