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
	
	@State private var useBorder = false
	
	public var body: some View {
		ZStack {
			switch type {
			case .systemImage(let name, let contentColor, _):
				Image(systemName: name)
					.resizable()
					.frame(width: size.size, height: size.size)
					.tint(contentColor)
					.onAppear {
						self.useBorder = true
					}
			case .icon(let icon):
				Image(icon)
					.resizable()
					.frame(width: size.size, height: size.size)
					.onAppear {
						self.useBorder = true
					}
			case .image(let user):
				if let avatarUrl = user.avatar, !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
					AsyncImage(url: url) { phase in
						if let image = phase.image {
							image
								.resizable()
								.aspectRatio(contentMode: .fill)
								.onAppear {
									self.useBorder = false
								}
						}
						else if phase.error != nil {
							Text(UserCfg.initials())
								.font(.system(size: size.size * 0.4, weight: .semibold))
								.foregroundColor(.white)
								.onAppear {
									self.useBorder = true
								}
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
						.onAppear {
							self.useBorder = true
						}
				}
			case .userCfg:
				if let avatarUrl = UserCfg.avatar(), !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
					AsyncImage(url: url) { phase in
						if let image = phase.image {
							image
								.resizable()
								.aspectRatio(contentMode: .fill)
								.onAppear {
									self.useBorder = false
								}
						}
						else if phase.error != nil {
							Text(UserCfg.initials())
								.font(.system(size: size.size * 0.4, weight: .semibold))
								.foregroundColor(.white)
								.onAppear {
									self.useBorder = true
								}
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
						.onAppear {
							self.useBorder = true
						}
				}
			}
		}
		.frame(width: size.size, height: size.size)
		.background(type.bgColor.gradient)
		.clipShape(.circle)
		.overlay {
			if self.useBorder {
				Circle()
					.stroke(Color.divider)
			}
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

struct AvatarGroup: View {
	
	let items: [AvatarType]
	var size: CGFloat
	
	/// **Dynamically generate size ratios that sum to 1.0**
	var sizeRatios: [CGFloat] {
		switch items.count {
		case 2: return [0.6, 0.4]
		case 3: return [0.6, 0.3, 0.3]
		default: return [size]
		}
	}
	
	/// **Calculate individual element sizes**
	var itemSizes: [CGFloat] {
		let totalAvailableSize = size * 0.8 // Total space for avatars
		return sizeRatios.map { $0 * totalAvailableSize }
	}
	
	public var body: some View {
		Group {
			if items.isEmpty {
				EmptyView()
			}
			else if items.count == 1 || items.count > 3 {
				Avatar(type: items[0], size: .custom(self.size), state: .normal)
			}
			else {
				ZStack {
					ForEach(items.indices, id: \.self) { index in
						Avatar(type: items[index], size: .custom(itemSizes[index]), state: .normal)
							.position(self.position(for: index))
					}
				}
				.frame(width: size, height: size)
				.background(Color.background.gradient)
				.clipShape(.circle)
			}
		}
		.overlay(alignment: .bottomTrailing) {
			if items.count > 3 {
				Circle()
					.fill(Color.background.gradient)
					.frame(width: size * 0.4, height: size * 0.4)
					.overlay {
						Text("\(items.count - 1)")
							.foregroundColor(.textPrimary)
							.font(.system(size: size * 0.3, weight: .semibold))
							.lineLimit(1)
							.padding(2)
					}
					.offset(x: 2, y: 1)
					.shadow(radius: 3)
			}
		}
	}
	
	/// Compute position for each avatar
	func position(for index: Int) -> CGPoint {
		let center = CGPoint(x: size / 2, y: size / 2)
		
		switch items.count {
		case 1:
			return center
		case 2:
			let offset1 = (size - itemSizes[0]) / 2 - 4
			let offset2 = (size - itemSizes[1]) / 2 - 4
			let positions = [
				CGPoint(x: center.x - offset1 + 1, y: center.y - offset1 + 1), // Top-left
				CGPoint(x: center.x + offset2 - 1, y: center.y + offset2 - 1)  // Bottom-right
			]
			return positions[index]
		case 3:
			let r1 = (size - itemSizes[0]) / 2 - 3
			let r2 = (size - itemSizes[1]) / 2 - 3
			let r3 = (size - itemSizes[2]) / 2 - 3
			let positions = [
				CGPoint(x: center.x - r1 + 1.5, y: center.y - r1 + 1.5), // Top-left
				CGPoint(x: center.x + r2, y: center.y - 2),              // Far right, slightly above center
				CGPoint(x: center.x, y: center.y + r3)                   // Bottom-center
			]
			return positions[index]
		default:
			return center
		}
	}
}
