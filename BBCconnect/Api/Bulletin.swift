//
//  Bulletin.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/23/25.
//

import Foundation

struct SanityBulletinResponse: Codable, Equatable {
	let query: String
	let result: [Bulletin]
}

enum BulletinType: String, Codable, Equatable {
	case general
	case alert
	case event
}

struct Bulletin: Codable, Equatable {
	let _id: String
	let title: String
	let content: String
	let type: BulletinType
	let date: String?
	let link: String?
	let image: String?
	let publishedAt: String
	
	var linkURL: URL? {
		if let link = self.link, let url = URL(string: link) {
			return url
		}
		
		return nil
	}
	
	var imageURL: URL? {
		if let image = self.image, let url = URL(string: image) {
			return url
		}
		
		return nil
	}
	
	var dateDate: Date? {
		if let date = self.date {
			return Date.fromCloudUpdatedAt(dateString: date)
		}
		
		return nil
	}
	
	func dateTimestamp(includeDow: Bool = true) -> String? {
		guard let date = self.dateDate else { return nil }
		
		let calendar = Calendar.current
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		formatter.timeZone = TimeZone.current
		
		if includeDow {
			if calendar.isDateInToday(date) {
				return "Today at \(formatter.string(from: date))"
			} else if calendar.isDateInYesterday(date) {
				return "Yesterday at \(formatter.string(from: date))"
			} else {
				formatter.dateFormat = "EEEE h:mm a" // "Saturday 3:30 PM"
				return formatter.string(from: date)
			}
		}
		
		return formatter.string(from: date)
	}
	
	var publishedDate: Date? {
		return Date.fromCloudUpdatedAt(dateString: self.publishedAt)
	}
	
	func publishedAtTimestamp(includeDow: Bool = true) -> String? {
		guard let date = self.publishedDate else { return nil }
		
		let calendar = Calendar.current
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		formatter.timeZone = TimeZone.current
		
		if includeDow {
			if calendar.isDateInToday(date) {
				return "Today at \(formatter.string(from: date))"
			} else if calendar.isDateInYesterday(date) {
				return "Yesterday at \(formatter.string(from: date))"
			} else {
				formatter.dateFormat = "EEEE h:mm a" // "Saturday 3:30 PM"
				return formatter.string(from: date)
			}
		}
		
		return formatter.string(from: date)
	}
}

struct BulletinPreview: Codable {
	let title: String?
	let description: String?
	let image: String?
}
