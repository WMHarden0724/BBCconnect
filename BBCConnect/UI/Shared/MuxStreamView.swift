//
//  MuxStreamView.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/9/25.
//

import SwiftUI
import AVKit

struct MuxLiveStreamView: View {
	
	@State private var isPlayerFullScreen = false
	
	private let url: String
	private let isLive: Bool
	private let title: String
	private let description: String?
	private let tracks: [OnDemandTrack]?
	private let enabled: Bool
	private let listenForStreamStatus: Bool
	
	init(url: String,
		 isLive: Bool = false,
		 title: String,
		 description: String?,
		 tracks: [OnDemandTrack]? = nil,
		 enabled: Bool = true,
		 listenForStreamStatus: Bool = false) {
		self.url = url
		self.isLive = isLive
		self.title = title
		self.description = description
		self.tracks = tracks
		self.enabled = enabled
		self.listenForStreamStatus = listenForStreamStatus
	}

	var body: some View {
		CardView {
			ZStack {
				VStack(spacing: 0) {
					SwiftUIPlayer(
						url: self.url,
						isPlayerFullScreen: self.$isPlayerFullScreen,
						isLive: self.isLive,
						timecodes: self.tracks?.map {
							Timecode(title: $0.name ?? "", time: CMTime(seconds: Double($0.duration ?? 0.0), preferredTimescale: 1))
						} ?? [],
						enabled: false,
						listenForStreamStatus: self.listenForStreamStatus
					)
					
					Text(self.title)
						.font(.headline)
						.foregroundColor(.primary)
						.frame(maxWidth: .infinity, alignment: .center)
						.padding(.top, Dimens.verticalPaddingMd)
					
					if let description = self.description, !description.isEmpty {
						Text(description)
							.font(.callout)
							.foregroundColor(.secondary)
							.frame(maxWidth: .infinity, alignment: .center)
							.padding(.top, Dimens.verticalPaddingSm)
					}
				}
				.padding(.bottom, Dimens.verticalPaddingMd)
				
				Color.clear
					.contentShape(Rectangle())
					.onTapGesture {
						self.isPlayerFullScreen = true
					}
			}
		}
	}
}
