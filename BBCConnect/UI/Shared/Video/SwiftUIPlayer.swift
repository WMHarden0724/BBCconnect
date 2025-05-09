// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 14.0, *)
public struct SwiftUIPlayer: View {
    
    @ObservedObject var viewModel: PlayerViewModel
	@Binding private var isPlayerFullScreen: Bool
	private let streamKey: String?
	private let showTimecodeList: Bool
	private let enabled: Bool
    
	public init(url: String,
				isPlayerFullScreen: Binding<Bool>,
				isLive: Bool = false,
				streamKey: String?,
				timecodes: [Timecode],
				showTimecodeList: Bool = false,
				enabled: Bool,
				listenForStreamStatus: Bool) {
		self.viewModel = PlayerViewModel(url: url, isLive: isLive, timecodes: timecodes, listenForStreamStatus: listenForStreamStatus)
		_isPlayerFullScreen = isPlayerFullScreen
		self.streamKey = streamKey
		self.showTimecodeList = showTimecodeList
		self.enabled = enabled
    }
    
    public var body: some View {
		VideoPlayerView(player: viewModel.player,
						isPlayerFullScreen: self.$isPlayerFullScreen,
						isLive: viewModel.isLive,
						streamKey: streamKey,
						timecodes: viewModel.timecodes,
						enabled: enabled)
		
		if showTimecodeList {
			TimecodeListView(player: viewModel.player,
							 timecodes: viewModel.timecodes)
		}
    }
}
