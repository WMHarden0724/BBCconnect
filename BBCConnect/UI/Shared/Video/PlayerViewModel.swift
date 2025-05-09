//
//  File.swift
//
//
//  Created by Айтолкун Анарбекова on 29.11.2023.
//

import Foundation
import AVKit

@available(iOS 14.0, *)
public class PlayerViewModel: ObservableObject {
	
	private let url: String
	public var isLive: Bool
	@Published var player = AVPlayer()
	public var timecodes: [Timecode]
	
	public init(url: String, isLive: Bool, timecodes: [Timecode], listenForStreamStatus: Bool) {
		self.url = url
		self.isLive = isLive
		self.timecodes = timecodes
		if let videoURL = URL(string: url) {
			self.player = AVPlayer(url: videoURL)
		}
		
		if listenForStreamStatus {
			self.startMonitoringStream()
		}
	}
	
	func startMonitoringStream() {
		try? AVAudioSession.sharedInstance().setCategory(.playback)
		try? AVAudioSession.sharedInstance().setActive(true)
		
		self.tryLoadStream()
		
		// Retry every 10 seconds
		Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] timer in
			guard let self = self else {
				timer.invalidate()
				return
			}
			
			print("Reloading stream")
			
			if self.player.currentItem?.status == .failed || self.player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
				self.tryLoadStream()
			}
		}
	}
	
	func tryLoadStream() {
		if let videoURL = URL(string: self.url) {
			let item = AVPlayerItem(url: videoURL)
			self.player.replaceCurrentItem(with: item)
		}
	}
}
