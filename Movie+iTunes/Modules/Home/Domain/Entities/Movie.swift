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
	var favorited: Bool
	var price: String
	var genre: String
	var poster: Poster
}

struct Poster: Hashable {
	var tiny: String
	var large: String
	var imageLarge: Data?
	var imageTiny: Data?
}
