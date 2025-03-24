//
//  News.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/23/25.
//

import Foundation

struct NewsResponse: Codable, Equatable {
	let news: [News]
	let total: Int
	let page: Int
	let totalPages: Int
}

enum NewsType: String, Codable, Equatable {
	case general
	case alert
	case event
}

struct News: Codable, Equatable {
	let id: Int
	let title: String
	let content: String
	let type: NewsType
	let date: String?
	let link: String?
	let image: String?
	let created_at: String
	let updated_at: String
	
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
		return Date.fromCloudUpdatedAt(dateString: self.created_at)
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
	
	var createdAtDate: Date? {
		return Date.fromCloudUpdatedAt(dateString: self.created_at)
	}
	
	func createdAtTimestamp(includeDow: Bool = true) -> String? {
		guard let date = self.createdAtDate else { return nil }
		
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
