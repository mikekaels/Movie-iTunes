//
//  Combine+CancelBag.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine

public class CancelBag {
	public var subscriptions = Set<AnyCancellable>()
	
	public func cancel() {
		subscriptions.forEach { $0.cancel() }
		subscriptions.removeAll()
	}
	
	public init() {}
}

extension AnyCancellable {
	public func store(in cancelBag: CancelBag) {
		cancelBag.subscriptions.insert(self)
	}
}
