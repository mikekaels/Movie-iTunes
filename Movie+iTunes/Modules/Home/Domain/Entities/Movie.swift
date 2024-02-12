//
//  Movie.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation

internal struct Movie: Hashable {
	let id: String
	let title: String
	let description: String
	let year: String
	let trailer: String
	let posterPath: String
	var image: Data?
	var favorited: Bool
	var price: String
	var genre: String
}

