//
//  ImageDependencyManager.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Kingfisher

internal enum ImageDependencyManager {
	static func setup() {
		let cache = ImageCache.default
		cache.memoryStorage.config.totalCostLimit = 1
	}
}
