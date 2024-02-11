//
//  MovieResponse.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

struct BaseResponse: Codable {
	let resultCount: Int?
	let results: [MovieResponse]
	
}

struct MovieResponse: Codable {
	let trackId: Int?
	let artistName, trackName: String?
	let trackViewUrl: String?
	let previewUrl: String?
	let artworkUrl30, artworkUrl60, artworkUrl100: String?
	let releaseDate: String?
	let shortDescription: String?
}

