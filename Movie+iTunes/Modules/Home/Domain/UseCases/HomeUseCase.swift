//
//  HomeUseCase.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine
import Networking

internal protocol HomeUseCaseProtocol {
	func searchMovies(keyword: String, genre: String, limit: Int) -> AnyPublisher<[Movie], ErrorResponse>
	func getFavorites() -> AnyPublisher<[Movie], Error>
	func saveFavorite(movie: Movie) -> AnyPublisher<Void, Error>
	func delete(movie: Movie) -> AnyPublisher<Void, Error>
	var savedMovies: [Movie] { get }
}

internal final class HomeUseCase {
	let movieRepository: MovieRepositoryProtocol
	var savedMovies: [Movie] = []
	
	init(movieRepository: MovieRepositoryProtocol = MovieRepository()) {
		self.movieRepository = movieRepository
	}
}

extension HomeUseCase: HomeUseCaseProtocol {
	func delete(movie: Movie) -> AnyPublisher<Void, Error> {
		movieRepository.delete(movie: movie)
	}
	
	func getFavorites() -> AnyPublisher<[Movie], Error> {
		movieRepository.getFavorites()
			.map { [weak self] movies -> [Movie] in
				self?.savedMovies = movies
				return movies
			}
			.eraseToAnyPublisher()
	}
	
	func saveFavorite(movie: Movie) -> AnyPublisher<Void, Error> {
		let semaphore = DispatchSemaphore(value: 0)
		var image: Data? = nil
		DispatchQueue.global().async { [weak self] in
			self?.movieRepository.getImageData(url: movie.posterPath) { imageData in
				image = imageData
				semaphore.signal()
			}
		}
		semaphore.wait()
		var movie = movie
		movie.image = image
		return movieRepository.saveFavorite(movie: movie)
	}
	
	func searchMovies(keyword: String, genre: String, limit: Int) -> AnyPublisher<[Movie], ErrorResponse> {
		movieRepository.searchMovies(keyword: keyword, genre: genre, limit: limit)
			.map { movies -> [Movie] in
				let newMovies = movies.map {
					var movie = $0
					movie.favorited = self.movieRepository.checkFavoriteStatusBy(movie: $0)
					return movie
				}
				return newMovies
			}
			.eraseToAnyPublisher()
	}
}
