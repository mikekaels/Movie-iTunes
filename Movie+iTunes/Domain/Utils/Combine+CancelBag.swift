//
//  Combine+CancelBag.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine

/// A class for managing cancellable subscriptions.
public class CancelBag {
	/// A set containing the cancellable subscriptions.
	public var subscriptions = Set<AnyCancellable>()
	
	/// Cancels all subscriptions and removes them from the bag.
	public func cancel() {
		subscriptions.forEach { $0.cancel() }
		subscriptions.removeAll()
	}
	
	/// Initializes a new instance of `CancelBag`.
	public init() {}
}

extension AnyCancellable {
	/// Stores the subscription in the specified `CancelBag`.
	///
	/// - Parameter cancelBag: The `CancelBag` to store the subscription in.
	public func store(in cancelBag: CancelBag) {
		cancelBag.subscriptions.insert(self)
	}
}

