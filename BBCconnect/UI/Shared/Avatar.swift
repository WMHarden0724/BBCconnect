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
		default: return Color.gray
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
	
	var fontSize: CGFloat {
		switch self {
		case .xxxxs: return 5
		case .xxxs: return 8
		case .xxs: return 10
		case .xs: return 12
		case .sm: return 14
		case .md: return 18
		case .lg: return 20
		case .xl: return 50
		case .custom(let size): return size * 0.4
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
		case .unread: return .errorMain
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
				.fill(state.bgColor)
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
	
	public var body: some View {
		ZStack {
			switch type {
			case .systemImage(let name, let contentColor, _):
				Image(systemName: name)
					.resizable()
					.frame(width: size.size, height: size.size)
					.tint(contentColor)
			case .icon(let icon):
				Image(icon)
					.resizable()
					.frame(width: size.size, height: size.size)
			case .image(let user):
				if let avatarUrl = user.avatar, !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
					AsyncImage(url: url) { phase in
						if let image = phase.image {
							image
								.resizable()
								.aspectRatio(contentMode: .fill)
						} else {
							Text(user.initials())
								.font(.system(size: size.fontSize, weight: .semibold))
								.foregroundColor(.textPrimary)
						}
					}
				}
				else {
					Text(user.initials())
						.font(.system(size: size.fontSize, weight: .semibold))
						.foregroundColor(.textPrimary)
				}
			case .userCfg:
				if let avatarUrl = UserCfg.avatar(), !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
					AsyncImage(url: url) { phase in
						if let image = phase.image {
							image
								.resizable()
								.aspectRatio(contentMode: .fill)
						} else {
							Text(UserCfg.initials())
								.font(.system(size: size.fontSize, weight: .semibold))
								.foregroundColor(.textPrimary)
						}
					}
				}
				else {
					Text(UserCfg.initials())
						.font(.system(size: size.fontSize, weight: .semibold))
						.foregroundColor(.textPrimary)
				}
			}
		}
		.frame(width: size.size, height: size.size)
		.background(type.bgColor.gradient)
		.clipShape(.circle)
		.overlay {
			Circle()
				.stroke(Color.primaryContrast.gradient)
		}
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


/// - Avatar Group Component Starts
enum AvatarGroupSize {
	case sm
	case md
	case lg
	
	var size: CGFloat {
		switch self {
		case .sm: return 24
		case .md: return 38
		case .lg: return 50
		}
	}
	
	var offset: CGFloat {
		switch self {
		case .sm:
			return 4
		case .md:
			return 8
		case .lg:
			return 18
		}
	}
	
	var avatarSize: AvatarSize {
		switch self {
		case .sm: return .xxxxs
		case .md: return .xxxs
		case .lg: return .xxs
		}
	}
	
	var badgeSize: CGFloat {
		switch self {
		case .sm: return 6
		case .md: return 8
		case .lg: return 12
		}
	}
	
	var badgeOffset: CGFloat {
		switch self {
		case .sm, .md: return -1
		default: return -3
		}
	}
}

struct AvatarGroup: View {
	
	let items: [AvatarType]
	var size: AvatarGroupSize = .lg
	var state: AvatarState
	
	public var body: some View {
		let itemCount = items.count
		if items.count == 0 {
			EmptyView()
		} else {
			ZStack {
				if itemCount > 0 {
					Avatar(type: items[0], size: size.avatarSize, state: .normal)
						.padding([.leading, .top], -size.offset)
				}
				
				Group {
					if itemCount > 2 {
						Circle()
							.fill(Color.gray.gradient)
							.frame(width: size.size, height: size.size)
							.overlay {
								Text("\(items.count - 1)")
									.foregroundColor(.textPrimary)
									.font(.system(size: 12, weight: .semibold))
									.lineLimit(1)
									.padding(2)
							}
							.padding([.leading, .top], size.offset)
					} else if itemCount > 1 {
						Avatar(type: items[1], size: size.avatarSize, state: .normal)
							.padding([.leading, .top], size.offset)
					}
				}
			}
			.frame(width: size.size, height: size.size)
			.background(Color.background.gradient)
			.clipShape(.circle)
			.overlay(alignment: .bottomTrailing) {
				if state != .normal {
					AvatarBadge(
						size: size.badgeSize,
						state: state
					)
					.offset(x: size.badgeOffset, y: size.badgeOffset)
				}
			}
		}
	}
}
