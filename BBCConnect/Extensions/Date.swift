//
//  Date.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import SwiftUI

public extension Date {
	var calendar: Calendar {
		// Workaround to segfault on corelibs foundation https://bugs.swift.org/browse/SR-10147
		return Calendar(identifier: Calendar.current.identifier)
	}
	
	var monthString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM"
		return dateFormatter.string(from: self)
	}
	
	var dayOfWeekString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEEEEE"
		return dateFormatter.string(from: self)
	}
	
	var addDay: Date {
		var dateComponents = DateComponents()
		dateComponents.day = 1
		return calendar.date(byAdding: dateComponents, to: self) ?? self
	}
	
	var addYear: Date {
		var dateComponents = DateComponents()
		dateComponents.month = 12
		return calendar.date(byAdding: dateComponents, to: self) ?? self
	}
	
	var dayOfMonth: Int {
		return calendar.dateComponents([.day], from: self).day ?? 0
	}
	
	var isThisMonth: Bool {
		let now = Date()
		return now.month == self.month && now.year == self.year
	}
	
	var isToday: Bool {
		return calendar.isDateInToday(self)
	}
	
	var month: Int {
		return calendar.component(.month, from: self)
	}
	
	var weekday: Int {
		return calendar.component(.weekday, from: self)
	}
	
	var weekOfMonth: Int {
		return calendar.component(.weekOfMonth, from: self)
	}
	
	var weekOfYear: Int {
		return calendar.dateComponents([.weekOfYear], from: self).weekOfYear ?? 0
	}
	
	var year: Int {
		return calendar.dateComponents([.year], from: self).year ?? 0
	}
	
	var yearsBetweenNow: Int {
		return Date().year - self.year
	}
	
	var toBeginningOfMonth: Date {
		let dateComponents = calendar.dateComponents([.year, .month], from: self)
		return calendar.startOfDay(for: calendar.date(from: dateComponents) ?? self)
	}
	
	var toEndOfMonth: Date {
		var dateComponents = DateComponents()
		dateComponents.month = 1
		dateComponents.day = -1
		return calendar.startOfDay(for: calendar.date(byAdding: dateComponents, to: self) ?? self)
	}
	
	func toDateString(format: String = "yyyy-MM-dd", timeZone: TimeZone? = nil) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		if let timeZone = timeZone {
			dateFormatter.timeZone = timeZone
		}
		return dateFormatter.string(from: self)
	}
	
	var timeIntervalSince1970Ms: Int {
		return Int(self.timeIntervalSince1970 * 1000)
	}
	
	func subtractDays(days: Int) -> Date {
		var dateComponents = DateComponents()
		dateComponents.day = -days
		return calendar.date(byAdding: dateComponents, to: self) ?? self
	}
	
	/// Computes the total nuber of days between two dates
	///
	/// - Parameters:
	///   - start: the start date
	///   - end: the end date
	/// - Returns: the total days or nil if unable to calculate
	static func daysBetween(start: Date, end: Date) -> Int? {
		return Calendar.current.dateComponents([.day], from: start, to: end).day
	}
	
	static func fromCloudUpdatedAt(dateString: String) -> Date? {
		let dateFormatter = Self.cloudUpdatedAtDateFormatter()
		let cloudUpdatedAt = dateFormatter.date(from: dateString)
		return cloudUpdatedAt
	}
	
	static func fromSanityPublishedAt(dateString: String) -> Date? {
		let dateFormatter = Self.sanityPublishedAtDateFormatter()
		let sanityPublishedAt = dateFormatter.date(from: dateString)
		return sanityPublishedAt
	}
	
	static func toCloudUpdatedAt() -> Date {
		let date = Date()
		let dateFormatter = Self.cloudUpdatedAtDateFormatter()
		let cloudUpdatedAt = Self.fromCloudUpdatedAt(dateString: dateFormatter.string(from: date)) ?? Date()
		return cloudUpdatedAt
	}
	
	static func toCloudUpdatedAtString() -> String {
		let date = toCloudUpdatedAt()
		return cloudUpdatedAtDateFormatter().string(from: date)
	}
	
	static func fromDateString(dateString: String, format: String = "yyyy-MM-dd", timeZone: TimeZone? = nil) -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		if let timeZone = timeZone {
			dateFormatter.timeZone = timeZone
		}
		return dateFormatter.date(from: dateString)
	}
	
	static func formatConversationLastMessageDate(dateString: String) -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		
		guard let date = dateFormatter.date(from: dateString) else { return nil }
		
		let calendar = Calendar.current
		let now = Date()
		
		if calendar.isDateInToday(date) {
			// Return time if today
			dateFormatter.dateFormat = "h:mm a"
			return dateFormatter.string(from: date)
		}
		else if calendar.isDateInYesterday(date) {
			return "Yesterday"
		}
		else if let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now),
				  date >= sevenDaysAgo {
			// Return weekday if within last 7 days
			dateFormatter.dateFormat = "EEEE"
			return dateFormatter.string(from: date)
		} else {
			// Return full date if older than 7 days
			dateFormatter.dateFormat = "MMM d, yyyy"
			return dateFormatter.string(from: date)
		}
	}
	
	private static func cloudUpdatedAtDateFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.locale = Locale(identifier: TimeZone.current.identifier)
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		return dateFormatter
	}
	
	private static func sanityPublishedAtDateFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		dateFormatter.locale = Locale(identifier: TimeZone.current.identifier)
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		return dateFormatter
	}
}
