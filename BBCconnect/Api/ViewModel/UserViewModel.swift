//
//  UserViewModel.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/17/25.
//

import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
	
	@Published var user: User?
	@Published var loadingState: APIResult<User> = .none
	
	func fetchUser() async {
		self.loadingState = .loading
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .userProfile)
		
		DispatchQueue.main.async {
			if case .success(let userData) = result {
				self.user = userData
			}
			
			self.loadingState = result
		}
	}
	
	func updateUserProfile(email: String? = nil, firstName: String? = nil, lastName: String? = nil, avatar: Data? = nil) async -> (User?, String?) {
		let result: APIResult<User> = await APIManager.shared.request(endpoint: .updateUserProfile, body: UpdateUserProfilePayload(email: email,
																																   first_name: firstName,
																																   last_name: lastName,
																																   avatar: avatar))
		
		if case .success(let data) = result {
			UserCfg.updateUser(user: data)
			return (data, nil)
		}
		else if case .failure(let error) = result {
			return (nil, error.localizedDescription)
		}
		
		return (nil, nil)
	}
}

@MainActor
open class UserSearchViewModel: ObservableObject {
	
	@Published var searchQuery = ""
	@Published var isError = false
	@Published var isLoading = false
	@Published var users = [User]()
	
	private var page = 0
	private let limit = 25
	private var totalPages = 1
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		self.searchUsers(reset: true, query: "")
		
		self.$searchQuery
			.debounce(for: .milliseconds(250), scheduler: RunLoop.main) // Delay API calls until user stops typing
			.removeDuplicates() // Prevent duplicate calls for the same query
			.sink { [weak self] newQuery in
				guard let self = self else { return }
				self.searchUsers(reset: true, query: newQuery)
			}
			.store(in: &self.cancellables)
	}
	
	deinit {
		self.cancellables.forEach { $0.cancel() }
	}
	
	func searchUsers(reset: Bool = false, query: String = "") {
		if reset {
			self.page = 0
			self.totalPages = 1
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
			let result: APIResult<SearchUsersResponse> = await APIManager.shared.request(endpoint: .getUsers, queryParams: queryParams)
			
			DispatchQueue.main.async {
				self.isLoading = false
				
				if case .success(let response) = result {
					self.isError = false
					if response.page == 1 {
						self.users = response.users
					}
					else {
						self.users.append(contentsOf: response.users)
					}
				}
				else if case .failure(_) = result {
					self.isError = true
				}
			}
		}
	}
}

fileprivate struct UpdateUserProfilePayload: Codable {
	let email: String?
	let first_name: String?
	let last_name: String?
	let avatar: String?
	
	init(email: String? = nil, first_name: String? = nil, last_name: String? = nil, avatar: Data? = nil) {
		self.email = email
		self.first_name = first_name
		self.last_name = last_name
		
		if let avatar = avatar {
			self.avatar = "data:image/png;base64,\(avatar.base64EncodedString())"
		}
		else {
			self.avatar = nil
		}
	}
}
