//
//  Log.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import os

struct LogUtils {
	
	static func createLogger(tag: String) -> Logger {
		var subsystem = "com.bbcbwk.BBCconnect"
		if let bundleID = Bundle.main.bundleIdentifier {
			subsystem = bundleID
		}
		return Logger(subsystem: subsystem, category: tag)
	}
}
