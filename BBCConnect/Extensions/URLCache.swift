//
//  URLCache.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/31/25.
//

import Foundation

extension URLCache {
	static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
