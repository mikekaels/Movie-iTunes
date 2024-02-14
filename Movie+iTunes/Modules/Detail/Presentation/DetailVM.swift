//
//  DetailVM.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation

final class DetailVM {
	let movie: Movie?
	
	init(movie: Movie? = nil) {
		print("~ MOVIE: ", movie)
		self.movie = movie
	}
	
	enum DataSourceType: Hashable {
		case header(Movie)
		case trailers(Movie)
	}
}

extension DetailVM {
	struct Action {
		
	}
	
	class State {
		@Published var dataSources: [DataSourceType] = []
		@Published var poster: Poster? = nil
	}
	
	func transform(_ action: Action, cancellables: CancelBag) -> State {
		let state = State()
		state.dataSources = [
			.header(movie!),
			.trailers(movie!),
		]
		state.poster = movie?.poster
		
		
		return state
	}
}
