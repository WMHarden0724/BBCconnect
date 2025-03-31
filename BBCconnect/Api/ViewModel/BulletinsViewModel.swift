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
	
	@Published var searchQuery = ""
	@Published var isError = false
	@Published var isLoading = false
	@Published var bulletins = [Bulletin]()
	@Published var canLoadMore = false
	
	@Published var newBulletinsAvailable = false
	
	private var page = 0
	private let limit = 25
	private var totalPages = 1
	
	private var cancellables = Set<AnyCancellable>()
	private let subManager = SubscriptionManager()
	
	init() {
		self.fetchBulletins(query: "")
		self.setupSubscribers()
		
		self.$searchQuery
			.debounce(for: .milliseconds(250), scheduler: RunLoop.main) // Delay API calls until user stops typing
			.removeDuplicates() // Prevent duplicate calls for the same query
			.sink { [weak self] newQuery in
				guard let self = self else { return }
				self.fetchBulletins(reset: true, query: newQuery)
			}
			.store(in: &self.cancellables)
	}
	
	func fetchBulletins(reset: Bool = false, query: String) {
		if reset {
			self.page = 0
			self.totalPages = 1
			self.canLoadMore = false
		}
		
		if self.page > self.totalPages {
			// We are on the last page
			return
		}
		
		self.isLoading = true
		
		// Load next page
		self.page = self.page + 1
		
		Task {
			let queryParams = [ "query": query, "page": self.page, "limit": self.limit ]
			let result: APIResult<SearchBulletinsResponse> = await APIManager.shared.request(endpoint: .getBulletins, queryParams: queryParams)
			
			DispatchQueue.main.async {
				self.isLoading = false
				
				if case .success(let response) = result {
					self.isError = false
					if response.page == 1 {
						self.bulletins = response.bulletins
					}
					else {
						self.bulletins.append(contentsOf: response.bulletins)
					}
					
					self.canLoadMore = response.page < response.total_pages
				}
				else if case .failure(_) = result {
					self.isError = true
				}
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
