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
	func checkFavoriteStatusBy(movie: Movie) -> Bool
}

internal final class HomeUseCase {
	let movieRepository: MovieRepositoryProtocol
	var savedMovies: [Movie] = []
	
	init(movieRepository: MovieRepositoryProtocol = MovieRepository()) {
		self.movieRepository = movieRepository
	}
}

extension HomeUseCase: HomeUseCaseProtocol {
	func checkFavoriteStatusBy(movie: Movie) -> Bool {
		movieRepository.checkFavoriteStatusBy(movie: movie)
	}
	
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
		var imageTiny: Data? = nil
		var imageLarge: Data? = nil
		DispatchQueue.global().async { [weak self] in
			self?.movieRepository.getImageData(url: movie.poster.tiny) { imageData in
				imageTiny = imageData
				semaphore.signal()
			}
			
			self?.movieRepository.getImageData(url: movie.poster.large) { imageData in
				imageLarge = imageData
				semaphore.signal()
			}
		}
		_ = semaphore.wait(timeout: .distantFuture)
		_ = semaphore.wait(timeout: .distantFuture)
		var movie = movie
		movie.poster.imageTiny = imageTiny
		movie.poster.imageLarge = imageLarge
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
