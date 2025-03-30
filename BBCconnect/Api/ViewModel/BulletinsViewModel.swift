//
//  BulletinsViewModel.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/23/25.
//

import Foundation
import Combine

@MainActor
class BulletinsViewModel: ObservableObject {
	
	@Published var loadingState: APIResult<BulletinsResponse> = .none
	@Published var bulletins = [Bulletin]()
	
	@Published var newBulletinsAvailable = false
	
	private var page = 0
	private var hasNextPage = false
	
	private let subManager = SubscriptionManager()
	
	init() {
		self.fetchBulletins()
		self.setupSubscribers()
	}
	
	func fetchBulletins(reset: Bool = false) {
		if reset {
			self.page = 0
		}
		
		// Load next page
		self.page = self.page + 1
		
		Task {
			let queryParams = [ "page": self.page ]
			let result: APIResult<BulletinsResponse> = await APIManager.shared.request(endpoint: .getBulletins, queryParams: queryParams)
			
			DispatchQueue.main.async {
				if case .success(let bulletins) = result {
					self.hasNextPage = bulletins.total_pages > self.page
					
					if reset {
						self.bulletins = bulletins.bulletins
					}
					else {
						self.bulletins.append(contentsOf: bulletins.bulletins)
					}
				}
				
				self.loadingState = result
			}
		}
	}
	
	private func setupSubscribers() {
		Task {
			await NotificationCenter.default.publisher(for: Notification.Name.PubSubMessage)
				.receive(on: DispatchQueue.main)
				.compactMap { $0.object as? PubSubMessage }
				.sink(receiveValue: { payload in
					guard payload.channel == .bulletins else { return }
					if payload.status == .create {
						DispatchQueue.main.async {
							self.newBulletinsAvailable = true
						}
					}
					else if payload.status == .delete {
						DispatchQueue.main.async {
							if let bulletinId = payload.bulletin_id {
								self.bulletins.removeAll(where: { $0.id == bulletinId })
							}
						}
					}
				})
				.storeIn(self.subManager)
		}
	}
}
