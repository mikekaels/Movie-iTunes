//
//  HomeUseCase.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine
import Networking

/// A protocol defining the operations supported by the home use case.
internal protocol HomeUseCaseProtocol {
	/// Searches for movies based on a keyword, genre, and limit.
	/// - Parameters:
	///   - keyword: The keyword to search for.
	///   - genre: The genre to filter the search by.
	///   - limit: The maximum number of movies to retrieve.
	/// - Returns: A publisher emitting an array of movies or an error.
	func searchMovies(keyword: String, genre: String, limit: Int) -> AnyPublisher<[Movie], ErrorResponse>
	
	/// Retrieves the user's favorite movies.
	/// - Returns: A publisher emitting an array of favorite movies or an error.
	func getFavorites() -> AnyPublisher<[Movie], Error>
	
	/// Saves a movie as a favorite.
	/// - Parameter movie: The movie to save as a favorite.
	/// - Returns: A publisher emitting the saved movie or an error.
	func saveFavorite(movie: Movie) -> AnyPublisher<Movie, Error>
	
	/// Deletes a movie from the favorites.
	/// - Parameter movie: The movie to delete from favorites.
	/// - Returns: A publisher emitting the deleted movie or an error.
	func delete(movie: Movie) -> AnyPublisher<Movie, Error>
	
	/// Retrieves the list of saved movies.
	var savedMovies: [Movie] { get }
	
	/// Checks if a movie is marked as a favorite.
	/// - Parameter movie: The movie to check.
	/// - Returns: `true` if the movie is a favorite, otherwise `false`.
	func checkFavoriteStatusBy(movie: Movie) -> Bool
}

/// The concrete implementation of the home use case.
internal final class HomeUseCase {
	/// The repository responsible for managing movies.
	let movieRepository: MovieRepositoryProtocol
	
	/// The list of saved movies.
	var savedMovies: [Movie] = []
	
	/// Initializes the home use case with a movie repository.
	/// - Parameter movieRepository: The repository for managing movies.
	init(movieRepository: MovieRepositoryProtocol = MovieRepository()) {
		self.movieRepository = movieRepository
	}
}


extension HomeUseCase: HomeUseCaseProtocol {
	func checkFavoriteStatusBy(movie: Movie) -> Bool {
		movieRepository.checkFavoriteStatusBy(movie: movie)
	}
	
	func delete(movie: Movie) -> AnyPublisher<Movie, Error> {
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
	
	func saveFavorite(movie: Movie) -> AnyPublisher<Movie, Error> {
		let semaphore = DispatchSemaphore(value: 0)
		var imageTiny: Data? = nil
		DispatchQueue.global().async { [weak self] in
			self?.movieRepository.getImageData(url: movie.poster.tiny) { imageData in
				imageTiny = imageData
				semaphore.signal()
			}
		}
		semaphore.wait()
		var movie = movie
		movie.poster.imageTiny = imageTiny
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
