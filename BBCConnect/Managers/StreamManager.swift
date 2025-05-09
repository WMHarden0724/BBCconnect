//
//  StreamManager.swift
//  BBCConnect
//
//  Created by Garrett Franks on 5/9/25.
//

import Foundation
import Combine

class StreamManager: ObservableObject {
	
	public static let shared = StreamManager()
	
	// MARK: Live Stream
	
	func loadLiveStreams() async -> APIResult<LiveStreamsResult> {
		let result: APIResult<LiveStreamsResult> = await APIManager.shared.request(endpoint: .getLiveStream)
		return result
	}
	
	func startLiveStream(title: String, description: String) async -> APIResult<LiveStreamResult> {
		let result: APIResult<LiveStreamResult> = await APIManager.shared.request(endpoint: .startLiveStream,
																			body: LiveStreamParams(title: title, description: description))
		return result
	}
	
	func stopLiveStream(_ id: String) async -> APIResult<APIMessage> {
		let result: APIResult<APIMessage> = await APIManager.shared.request(endpoint: .stopLiveStream(id))
		return result
	}
	
	// MARK: On-Demand
	
	func loadOnDemand() async -> APIResult<OnDemandAssets> {
		let result: APIResult<OnDemandAssets> = await APIManager.shared.request(endpoint: .getOnDemand)
		return result
	}
}
