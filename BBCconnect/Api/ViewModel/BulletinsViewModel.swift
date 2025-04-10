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
	
	@Published var isError = false
	@Published var isLoading = false
	@Published var bulletins = [Bulletin]()
	@Published var canLoadMore = false
		
	private var page = 0
	private let limit = 10
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		self.fetchBulletins()
	}
	
	func fetchBulletins(reset: Bool = false) {
		if reset {
			self.page = 0
			self.canLoadMore = false
		}
		
		self.isLoading = true
		
		// Load next page
		self.page = self.page + 1
		
		Task {
			let result: APIResult<SanityBulletinResponse> = await APIManager.shared.request(url: self.buildUrl(), method: .get, includeSessionToken: false)
			
			DispatchQueue.main.async {
				self.isLoading = false
				
				if case .success(let response) = result {
					self.isError = false
					if self.page == 1 {
						self.bulletins = response.result
					}
					else {
						self.bulletins.append(contentsOf: response.result)
					}
					
					self.canLoadMore = response.result.count == self.limit
				}
				else if case .failure(let error) = result {
					print(error.localizedDescription)
					self.isError = true
				}
			}
		}
	}
	
	private func buildUrl() -> URL {
		let start = (self.page - 1) * self.limit;
		let end = start + self.limit;
		
		let query = "*[_type == \"bulletin\"]|order(publishedAt desc)[\(start)...\(end)]{_id,title,content,link,type,image,date,publishedAt}"
		let url = "https://3pa9o2xw.api.sanity.io/v2024-01-01/data/query/production?query=\(query)"
		return URL(string: url)!
	}
}
