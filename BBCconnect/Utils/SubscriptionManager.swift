//
//  SubscriptionManager.swift
//  BBCconnect
//
//  Created by Garrett Franks on 3/19/25.
//

import Combine

public actor SubscriptionManager {
	private var subscriptions = Set<AnyCancellable>()
	
	public init() {}
	
	public func store(_ cancellable: AnyCancellable?) {
		if let cancellable = cancellable {
			subscriptions.insert(cancellable)
		}
	}
	
	public func cancelAll() {
		subscriptions.removeAll()
	}
	
	deinit {
		subscriptions.forEach { $0.cancel() }
	}
}

public extension AnyCancellable {
	func storeIn(_ sm: SubscriptionManager) async {
		await sm.store(self)
	}
}
