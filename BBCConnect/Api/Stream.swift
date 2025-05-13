//
//  LiveStream.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/9/25.
//

import Foundation

struct LiveStreamParams: Codable {
	let title: String
	let description: String
}

struct LiveStreamsResult: Codable, Equatable {
	let livestreams: [LiveStream]?
}

struct LiveStreamResult: Codable, Equatable {
	let livestream: LiveStream?
}

struct LiveStream: Codable, Equatable {
	let info: LiveStreamDetails
	let metadata: StreamMetadata?
}

struct OnDemandAssets: Codable, Equatable {
	let assets: [OnDemand]?
	let page: Int
	let total: Int
}

struct OnDemand: Codable, Equatable {
	let info: OnDemandDetails
	let metadata: StreamMetadata?
}

struct LiveStreamDetails: Codable, Equatable {
	let id: String
	let active_asset_id: String?
	let recent_asset_id: String?
	let status: String
	let stream_key: String
	let playback_ids: [PlaybackId]
	let passthrough: String?
	let audio_only: Bool?
	let reduced_latency: Bool?
	let low_latency: Bool?
	let created_at: String
}

struct OnDemandDetails: Codable, Equatable {
	let id: String?
	let live_stream_id: String?
	let status: String?
	let duration: Float?
	let aspect_ratio: String?
	let upload_id: String?
	let stream_key: String?
	let playback_ids: [PlaybackId]?
	let tracks: [OnDemandTrack]?
	let is_live: Bool?
	let created_at: String
}

struct StreamMetadata: Codable, Equatable {
	let id: Int
	let title: String?
	let description: String?
	let stream_id: String?
	let asset_id: String?
}

struct PlaybackId: Codable, Equatable {
	let id: String
	let policy: String
	
	var url: String {
		return "https://stream.mux.com/\(self.id).m3u8"
	}
}

struct OnDemandTrack: Codable, Equatable {
	let id: String?
	let type: String?
	let duration: Float?
	let max_width: Int?
	let max_height: Int?
	let max_frame_rate: Float?
	let max_channels: Int?
	let max_channel_layout: String?
	let text_type: String?
	let name: String?
	let passthrough: String?
}
