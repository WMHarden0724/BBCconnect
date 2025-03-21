//
//  Conversation.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/18/25.
//

import Foundation

/// POST /api/conversation
public struct ConversationCreate: Codable, Equatable {
	public let name: String
	public let message: String
	public let user_ids: [Int]
}

public struct ConversationUpdate: Codable, Equatable {
	public let name: String?
	public let user_ids: [Int]?
}

/// RESPONSE /api/conversation
/// GET /api/conversation
public struct Conversation: Codable, Equatable, Hashable, Identifiable {
	public let id: Int
	public let name: String
	public let owner_id: Int
	public let users: [User]
	public let last_message: ConversationMessage
	public let deleted: Bool
	public let unread_count: Int
	public let created_at: String
	public let updated_at: String
	
	var sortedUsers: [User] {
		return self.users.sorted { $0.id == self.owner_id && $1.id != self.owner_id }
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
				return "Created today at \(formatter.string(from: date))"
			} else if calendar.isDateInYesterday(date) {
				return "Created yesterday at \(formatter.string(from: date))"
			} else {
				formatter.dateFormat = "Created on EEEE h:mm a" // "Saturday 3:30 PM"
				return formatter.string(from: date)
			}
		}
		
		return formatter.string(from: date)
	}
}

/// RESPONSE  /api/conversations/:id/messages
/// GET /api/conversations/:id/messages
public struct ConversationMessage: Codable, Equatable, Hashable {
	public let id: Int
	public let conversation_id: Int
	public let user: User
	public let content: String
	public let likes: [ConversationMessageLike]?
	public let deleted: Bool
	public let edited: Bool
	public let created_at: String
	public let updated_at: String
	
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
				return "Today \(formatter.string(from: date))"
			} else if calendar.isDateInYesterday(date) {
				return "Yesterday \(formatter.string(from: date))"
			} else {
				formatter.dateFormat = "EEEE h:mm a" // "Saturday 3:30 PM"
				return formatter.string(from: date)
			}
		}
		
		return formatter.string(from: date)
	}
}

public struct ConversationMessageLike: Codable, Equatable, Hashable {
	public let id: Int
	public let message_id: Int
	public let user_id: Int
	public let emoji: String
}

/// POST /api/conversations/:id/messages
public struct ConversationMessageCreate: Codable, Equatable {
	public let content: String
}

/// DELETE /api/conversations/:id
/// DELETE /api/messages/:id
/// POST /api/messages/:id/like
/// DELETE /api/messages/:id/like

extension Conversation {
	static let sampleConversations: [Conversation] = [
		Conversation(id: 1,
					 name: "Test 1",
					 owner_id: 2,
					 users: [],
					 last_message: ConversationMessage(id: 1,
													   conversation_id: 1,
													   user: User.sampleUser1,
													   content: "Hey, how are you?",
													   likes: nil,
													   deleted: false,
													   edited: false,
													   created_at: "2025-03-18T10:30:00Z",
													   updated_at: "2025-03-18T10:30:00Z"),
					 deleted: false,
					 unread_count: 0,
					 created_at: "2025-03-18T10:30:00Z",
					 updated_at: "2025-03-18T10:30:00Z"
					),
		Conversation(id: 2,
					 name: "Test 2",
					 owner_id: 2,
					 users: [],
					 last_message: ConversationMessage(id: 2,
													   conversation_id: 2,
													   user: User.sampleUser2,
													   content: "See you at the meeting!",
													   likes: nil,
													   deleted: false,
													   edited: false,
													   created_at: "2025-03-17T14:00:00Z",
													   updated_at: "2025-03-17T14:00:00Z"),
					 deleted: false,
					 unread_count: 1,
					 created_at: "2025-03-17T14:00:00Z",
					 updated_at: "2025-03-17T14:00:00Z"),
		Conversation(id: 3,
					 name: "Test 3",
					 owner_id: 2,
					 users: [],
					 last_message: ConversationMessage(id: 3,
													   conversation_id: 3,
													   user: User.sampleUser2,
													   content: "See you at the meeting!",
													   likes: nil,
													   deleted: false,
													   edited: false,
													   created_at: "2025-03-17T14:00:00Z",
													   updated_at: "2025-03-17T14:00:00Z"),
					 deleted: false,
					 unread_count: 2,
					 created_at: "2025-03-15T09:15:00Z",
					 updated_at: "2025-03-15T09:15:00Z")
	]
}

extension ConversationMessage {
	static let sampleMessages: [ConversationMessage] = [
		ConversationMessage(id: 1,
							conversation_id: 1,
							user: User.sampleUser1,
							content: "Hello there!",
							likes: [],
							deleted: false,
							edited: false,
							created_at: "2025-03-18T10:30:00Z",
							updated_at: "2025-03-18T10:30:00Z"),
		ConversationMessage(id: 2,
							conversation_id: 1,
							user: User.sampleUser2,
							content: "Hy how are you!",
							likes: [],
							deleted: false,
							edited: false,
							created_at: "2025-03-18T10:30:00Z",
							updated_at: "2025-03-18T10:30:00Z")
	]
}
