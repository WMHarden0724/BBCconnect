//
//  NewsViewModel.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/23/25.
//

import Foundation
import Combine

@MainActor
class NewsViewModel: ObservableObject {
	
	@Published var loadingState: APIResult<NewsResponse> = .none
	@Published var news = [News]()
	
	@Published var newNewsAvailable = false
	
	private var page = 0
	private var hasNextPage = false
	
	private let subManager = SubscriptionManager()
	
	init() {
		self.fetchNews()
		self.setupSubscribers()
	}
	
	func fetchNews(reset: Bool = false) {
		if reset {
			self.page = 0
		}
		
		// Load next page
		self.page = self.page + 1
		
		Task {
			let queryParams = [ "page": self.page ]
			let result: APIResult<NewsResponse> = await APIManager.shared.request(endpoint: .getNews, queryParams: queryParams)
			
			DispatchQueue.main.async {
				if case .success(let news) = result {
					self.hasNextPage = news.total_pages > self.page
					
					if reset {
						self.news = news.news
					}
					else {
						self.news.append(contentsOf: news.news)
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
					guard payload.channel == .news else { return }
					if payload.status == .create {
						DispatchQueue.main.async {
							self.newNewsAvailable = true
						}
					}
					else if payload.status == .delete {
						DispatchQueue.main.async {
							if let newsId = payload.news_id {
								self.news.removeAll(where: { $0.id == newsId })
							}
						}
					}
				})
				.storeIn(self.subManager)
		}
	}
}
