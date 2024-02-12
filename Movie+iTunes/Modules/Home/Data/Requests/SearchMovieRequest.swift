//
//  SearchMovieRequest.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Networking

internal struct SearchMovieRequest: APIRequest {
	
	typealias Response = [Movie]
	
	init(keyword: String, genre: String = "", limit: Int = 50) {
		if genre.isEmpty {
			path = "/search?term=\(keyword)&media=movie&limit=\(limit)"
		} else {
			path = "/search?term=\(genre)&entity=movie&attribute=genreTerm&limit=\(limit)"
		}
	}
	
	var baseURL: String = Constant.iTunes.baseURL
	
	var method: HTTPMethod = .get
	
	var path: String = ""
	
	var headers: [String : Any] = [:]
	
	var body: [String : Any] = [:]
	
	func map(_ data: Data) throws -> [Movie] {
		let decoded = try JSONDecoder().decode(BaseResponse.self, from: data)
		let movies = decoded.results.map {
			let year = $0.releaseDate ?? ""
			var poster = $0.artworkUrl100 ?? ""
			if let range = poster.range(of: "/100x100bb") {
				poster.replaceSubrange(range, with: "/350x350bb")
			}
			return Movie(id: String($0.trackId ?? 0),
						 title: $0.trackName ?? "",
						 description: $0.longDescription ?? "",
						 year: String(year.prefix(4)),
						 trailer: $0.trackViewUrl ?? "",
						 posterPath: poster,
						 image: nil,
						 favorited: false,
						 price: String($0.trackPrice ?? 0), 
						 genre: $0.primaryGenreName ?? ""
			)
		}
		return movies
	}
}


