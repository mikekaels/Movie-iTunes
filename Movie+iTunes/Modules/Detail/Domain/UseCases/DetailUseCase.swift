//
//  DetailUseCase.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 15/02/24.
//

import Foundation

internal protocol DetailUseCaseProtocol {
	func checkFavoriteStatusBy(movie: Movie) -> Bool
}

internal final class DetailUseCase {
	let movieRepository: MovieRepositoryProtocol
	
	init(movieRepository: MovieRepositoryProtocol = MovieRepository()) {
		self.movieRepository = movieRepository
	}
}

extension DetailUseCase: DetailUseCaseProtocol {
	func checkFavoriteStatusBy(movie: Movie) -> Bool {
		movieRepository.checkFavoriteStatusBy(movie: movie)
	}
}
