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
	let longDescription: String?
	let primaryGenreName: String?
	let trackPrice: Double?
}

//struct MovieResponse: Codable {
//	public let wrapperType, kind: String?
//	public let trackId: Int?
//	public let artistName, trackName, trackCensoredName: String?
//	public let trackViewUrl: String?
//	public let previewUrl: String?
//	public let artworkUrl30, artworkUrl60, artworkUrl100: String?
//	public let collectionPrice, trackPrice, trackRentalPrice, collectionHdPrice: Double?
//	public let trackHdPrice, trackHdRentalPrice: Double?
//	public let releaseDate: String?
//	public let collectionExplicitness, trackExplicitness: String?
//	public let trackTimeMillis: Int?
//	public let country, currency, primaryGenreName, contentAdvisoryRating: String?
//	public let shortDescription, longDescription: String?
//	public let hasITunesExtras: Bool?
//	public let collectionId: Int?
//	public let collectionName, collectionCensoredName: String?
//	public let collectionArtistId: Int?
//	public let collectionArtistViewUrl, collectionViewUrl: String?
//	public let discCount, discNumber, trackCount, trackNumber: Int?
//}
