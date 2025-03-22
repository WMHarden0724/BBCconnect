//
//  GroupAvatarImageView.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import SwiftUI

/// - Avatar Component Starts
public enum AvatarType {
	case systemImage(String, Color, Color)
	case icon(String)
	case image(User)
	case userCfg
	
	var bgColor: Color {
		switch self {
		case .systemImage(_, _, let color): return color
		default: return Color.avatar
		}
	}
}

@available(iOS 13.0, *)
public enum AvatarSize {
	case xxxxs, xxxs, xxs, xs, sm, md, lg, xl, custom(CGFloat)
	
	var size: CGFloat {
		switch self {
		case .xxxxs: 12
		case .xxxs: 18
		case .xxs: 24
		case .xs: 32
		case .sm: 40
		case .md: 48
		case .lg: 56
		case .xl: 150
		case .custom(let size): size
		}
	}
	
	var badgeSize: CGFloat {
		switch self {
		case .xxxxs: return 5
		case .xxxs: return 8
		case .xxs: return 10
		case .xs: return 12
		case .sm: return 14
		case .md: return 16
		case .lg: return 18
		case .xl: return 50
		case .custom(let size): return size * 0.3
		}
	}
	
	var badgeTextSize: CGFloat {
		switch self {
		case .xxxxs: return 2
		case .xxxs: return 4
		case .xxs: return 6
		case .xs, .sm: return 8
		case .md, .lg: return 12
		case .xl: return 20
		case .custom(let size): return size * 0.2
		}
	}
	
	var offset: CGFloat {
		switch self {
		case .xxxxs, .xxxs, .xxs, .xs: return 1
		default: return 3
		}
	}
}

public enum AvatarState {
	case normal
	case unread
	case online
	case offline
	
	var bgColor: Color {
		switch self {
		case .unread: return .blue
		case .online: return .green
		case .offline: return .green.opacity(0.5)
		default: return .clear
		}
	}
}


@available(iOS 15.0.0, *)
public struct AvatarBadge: View {
	
	var size: CGFloat
	var state: AvatarState
	
	public var body: some View {
		ZStack {
			Circle()
				.fill(state.bgColor.gradient)
				.frame(width: size, height: size)
				.overlay {
					if state != .unread {
						Circle()
							.stroke(.white, lineWidth: 2)
					}
				}
		}
	}
}

struct Avatar: View {
	
	var type: AvatarType
	var size: AvatarSize
	var state: AvatarState
	
	init(type: AvatarType, size: AvatarSize, state: AvatarState) {
		self.type = type
		self.size = size
		self.state = state
	}
	
	public var body: some View {
		ZStack {
			switch type {
			case .systemImage(let name, let contentColor, _):
				Image(systemName: name)
					.font(.system(size: size.size * 0.4, weight: .semibold))
					.foregroundColor(contentColor)
					.frame(width: size.size, height: size.size)
					.background(type.bgColor)
			case .icon(let icon):
				Image(icon)
					.resizable()
					.frame(width: size.size, height: size.size)
					.background(type.bgColor)
			case .image(let user):
				Group {
					if let avatarUrl = user.avatar, !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
						AsyncImage(url: url) { phase in
							if let image = phase.image {
								image
									.resizable()
									.aspectRatio(contentMode: .fill)
							}
							else if phase.error != nil {
								Text(UserCfg.initials())
									.font(.system(size: size.size * 0.4, weight: .semibold))
									.foregroundColor(.white)
							}
							else {
								Text(user.initials())
									.font(.system(size: size.size * 0.4, weight: .semibold))
									.foregroundColor(.white)
							}
						}
					}
					else {
						Text(user.initials())
							.font(.system(size: size.size * 0.4, weight: .semibold))
							.foregroundColor(.white)
					}
				}
				.frame(width: size.size, height: size.size)
				.background(type.bgColor.gradient)
			case .userCfg:
				Group {
					if let avatarUrl = UserCfg.avatar(), !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
						AsyncImage(url: url) { phase in
							if let image = phase.image {
								image
									.resizable()
									.aspectRatio(contentMode: .fill)
							}
							else if phase.error != nil {
								Text(UserCfg.initials())
									.font(.system(size: size.size * 0.4, weight: .semibold))
									.foregroundColor(.white)
							}
							else {
								Text(UserCfg.initials())
									.font(.system(size: size.size * 0.4, weight: .semibold))
									.foregroundColor(.white)
							}
						}
					}
					else {
						Text(UserCfg.initials())
							.font(.system(size: size.size * 0.4, weight: .semibold))
							.foregroundColor(.white)
					}
				}
				.frame(width: size.size, height: size.size)
				.background(type.bgColor.gradient)
			}
		}
		.clipShape(.circle)
		.overlay(alignment: .bottomTrailing) {
			if state != .normal {
				AvatarBadge(
					size: size.badgeSize,
					state: state
				)
				.offset(x: size.offset, y: size.offset)
			}
		}
	}
}
/// - Avatar Component Ends

struct AvatarGroup: View {
	
	private let users: [User]
	private let width: CGFloat
	private let height: CGFloat
	private let includeBackground: Bool
	
	var isWide: Bool {
		return width != height
	}
	
	var sizeMultipliers: [CGFloat] {
		let count = users.count
		switch count {
		case 2: return isWide ? [0.6, 0.4] : [0.5, 0.3]
		case 3: return isWide ? [0.55, 0.4, 0.25] : [0.5, 0.3, 0.25]
		case 4: return isWide ? [0.55, 0.3, 0.25, 0.2] : [0.5, 0.3, 0.3, 0.2]
		case 5: return isWide ? [0.55, 0.3, 0.25, 0.2, 0.175] : [0.5, 0.3, 0.3, 0.2, 0.15]
		case 6: return isWide ? [0.55, 0.3, 0.25, 0.2, 0.175, 0.15] : [0.5, 0.3, 0.25, 0.2, 0.15, 0.12]
		case 7: return isWide ? [0.55, 0.3, 0.25, 0.2, 0.175, 0.15, 0.15] : [0.5, 0.3, 0.25, 0.2, 0.15, 0.12, 0.12]
		default: return [1.0]
		}
	}
	
	init(users: [User], size: CGFloat, includeBackground: Bool = true) {
		self.users = users
		self.width = size
		self.height = size
		self.includeBackground = includeBackground
	}
	
	init(users: [User], width: CGFloat, height: CGFloat, includeBackground: Bool = true) {
		self.users = users
		self.width = width
		self.height = height
		self.includeBackground = includeBackground
	}
	
	var body: some View {
		Group {
			if users.isEmpty {
				EmptyView()
			}
			else if users.count == 1 || users.count > 7 {
				Avatar(type: .image(users[0]), size: .custom((width + height) / 2), state: .normal)
			}
			else {
				ZStack {
					ForEach(Array(users.enumerated()), id: \.element) { index, imageName in
						Avatar(type: .image(users[index]), size: .custom(((width + height) / 2) * sizeMultipliers[index]), state: .normal)
							.offset(x: self.position(for: index).x, y: self.position(for: index).y)
					}
				}
				.frame(width: width, height: height)
				.background(self.includeBackground ? Color.background.gradient : Color.clear.gradient)
				.if(!isWide) { view in
					view.clipShape(.circle)
				}
			}
		}
		.overlay(alignment: .bottomTrailing) {
			if users.count > 7 {
				Circle()
					.fill(Color.background.gradient)
					.frame(width: width * 0.4, height: height * 0.4)
					.overlay {
						Text("+\(users.count - 1)")
							.foregroundColor(.primary)
							.font(.system(size: ((width + height) / 2) * 0.2, weight: .semibold))
							.lineLimit(1)
							.padding(2)
					}
					.offset(x: 2, y: 1)
					.shadow(radius: 3)
			}
		}
	}
	
	private func position(for index: Int) -> CGPoint {
		let count = users.count
		switch index {
		case 1:
			switch count {
			case 2:
				if isWide {
					return CGPoint(x: width * 0.25, y: height * 0.2)
				}
				return CGPoint(x: width * 0.2, y: height * 0.2)
			case 3:
				if isWide {
					return CGPoint(x: width * 0.255, y: height * -0.09)
				}
				return CGPoint(x: width * 0.275, y: height * 0.1)
			case 4:
				if isWide {
					return CGPoint(x: width * 0.225, y: height * -0.09)
				}
				return CGPoint(x: width * 0.275, y: height * 0.1)
			case 5:
				if isWide {
					return CGPoint(x: width * 0.2, y: height * -0.2)
				}
				return CGPoint(x: width * 0.275, y: height * 0.1)
			case 6:
				if isWide {
					return CGPoint(x: width * 0.2, y: height * -0.2)
				}
				return CGPoint(x: width * 0.25, y: height * 0.07)
			case 7:
				if isWide {
					return CGPoint(x: width * 0.18, y: height * -0.2)
				}
				return CGPoint(x: width * 0.25, y: height * 0.07)
			default:
				return CGPoint(x: 0, y: 0)
			}
		case 2:
			switch count {
			case 2:
				if isWide {
					return CGPoint(x: width * 0.1, y: height * 0.4)
				}
				return CGPoint(x: width * 0.1, y: height * 0.4)
			case 3:
				if isWide {
					return CGPoint(x: width * 0.07, y: height * 0.28)
				}
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 4:
				if isWide {
					return CGPoint(x: width * 0.09, y: height * 0.275)
				}
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 5:
				if isWide {
					return CGPoint(x: width * 0.15, y: height * 0.15)
				}
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 6:
				if isWide {
					return CGPoint(x: width * 0.15, y: height * 0.15)
				}
				return CGPoint(x: width * 0.01, y: height * 0.255)
			case 7:
				if isWide {
					return CGPoint(x: width * 0.125, y: height * 0.15)
				}
				return CGPoint(x: width * 0.01, y: height * 0.255)
			default:
				return CGPoint(x: 0, y: 0)
			}
		case 3:
			switch count {
			case 2:
				return CGPoint(x: width * 0.1, y: height * 0.4)
			case 3:
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 4:
				if isWide {
					return CGPoint(x: width * 0.35, y: height * 0.22)
				}
				return CGPoint(x: width * 0.25, y: height * -0.2)
			case 5, 6:
				if isWide {
					return CGPoint(x: width * 0.375, y: height * 0.05)
				}
				return CGPoint(x: width * 0.25, y: height * -0.2)
			case 7:
				if isWide {
					return CGPoint(x: width * 0.325, y: height * 0.05)
				}
				return CGPoint(x: width * 0.25, y: height * -0.2)
			default:
				return CGPoint(x: 0, y: 0)
			}
		case 4:
			switch count {
			case 2:
				return CGPoint(x: width * 0.1, y: height * 0.4)
			case 3, 4:
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 5:
				if isWide {
					return CGPoint(x: width * -0.05, y: height * 0.325)
				}
				return CGPoint(x: width * -0.25, y: height * 0.215)
			case 6:
				if isWide {
					return CGPoint(x: width * -0.05, y: height * 0.325)
				}
				return CGPoint(x: width * -0.2, y: height * 0.21)
			case 7:
				if isWide {
					return CGPoint(x: width * -0.05, y: height * 0.325)
				}
				return CGPoint(x: width * -0.2, y: height * 0.21)
			default:
				return CGPoint(x: 0, y: 0)
			}
		case 5:
			switch count {
			case 2:
				return CGPoint(x: width * 0.1, y: height * 0.4)
			case 3, 4, 5:
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 6:
				if isWide {
					return CGPoint(x: width * 0.325, y: height * 0.3)
				}
				return CGPoint(x: width * 0.215, y: height * 0.3)
			case 7:
				if isWide {
					return CGPoint(x: width * 0.3, y: height * 0.275)
				}
				return CGPoint(x: width * 0.215, y: height * 0.3)
			default:
				return CGPoint(x: 0, y: 0)
			}
		case 6:
			switch count {
			case 2:
				return CGPoint(x: width * 0.1, y: height * 0.4)
			case 3, 4, 5, 6:
				return CGPoint(x: width * 0.0, y: height * 0.275)
			case 7:
				if isWide {
					return CGPoint(x: width * 0.3875, y: height * -0.155)
				}
				return CGPoint(x: width * 0.125, y: height * -0.35)
			default:
				return CGPoint(x: 0, y: 0)
			}
		default:
			switch count {
			case 2, 3, 4, 5, 6, 7:
				if isWide {
					return CGPoint(x: width * -0.2, y: height * -0.1)
				}
				return CGPoint(x: width * -0.125, y: height * -0.125)
			default:
				return CGPoint(x: 0, y: 0)
			}
		}
	}
}

struct AvatarGroupInline : View {
	
	let users: [User]
	let size: CGFloat
	let strokeColor: Color
	
	var width: CGFloat {
		let count = self.users.count - 1
		let halfSize = self.size / 2
		return (self.size + (halfSize * CGFloat(count))) - 2
	}
	
	var body: some View {
		ZStack {
			ForEach(Array(self.users.enumerated()), id: \.element) { index, user in
				Avatar(type: .image(user), size: .custom(self.size), state: .normal)
					.overlay {
						Circle()
							.stroke(self.strokeColor, lineWidth: 2)
					}
					.position(x: (index > 0 ? (self.size / 2) * CGFloat(index + 1) : self.size / 2) - 2,
							  y: self.size / 2)
					.zIndex(Double(self.users.count - index))
			}
		}
		.frame(width: self.width, height: self.size)
	}
}

//#Preview {
//	VStack(alignment: .leading) {
//		AvatarGroupInline(users: [User.sampleUser1, User.sampleUser2], size: 40, strokeColor: .backgroundDark)
//		
//		Avatar(type: .image(User.sampleUser1), size: .custom(40), state: .normal)
//
//		HStack {
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2], size: 200)
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2], width: 200, height: 150, isInNav: true)
//		}
//		
//		HStack {
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3], size: 200)
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3], width: 200, height: 150, isInNav: true)
//		}
//		
//		HStack {
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4], size: 200)
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4], width: 200, height: 150, isInNav: true)
//		}
//		
//		HStack {
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4, User.sampleUser5], size: 200)
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4, User.sampleUser5], width: 200, height: 150, isInNav: true)
//		}
//		
//		HStack {
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4, User.sampleUser5, User.sampleUser6], size: 200)
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4, User.sampleUser5, User.sampleUser6], width: 200, height: 150, isInNav: true)
//		}
//		
//		HStack {
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4, User.sampleUser5, User.sampleUser6, User.sampleUser7], size: 200)
//			AvatarGroup(users: [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.sampleUser4, User.sampleUser5, User.sampleUser6, User.sampleUser7], width: 200, height: 150, isInNav: true)
//		}
//	}
//}
