//
//  MovieRepository.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Networking
import Combine
import Persistence
import Kingfisher

/// A protocol defining the operations supported by the movie repository.
internal protocol MovieRepositoryProtocol {
	/// Searches for movies based on a keyword, genre, and limit.
	/// - Parameters:
	///   - keyword: The keyword to search for.
	///   - genre: The genre to filter the search by.
	///   - limit: The maximum number of movies to retrieve.
	/// - Returns: A publisher emitting an array of movies or an error.
	func searchMovies(keyword: String, genre: String, limit: Int) -> AnyPublisher<[Movie], ErrorResponse>
	
	/// Saves a movie as a favorite.
	/// - Parameter movie: The movie to save as a favorite.
	/// - Returns: A publisher emitting the saved movie or an error.
	func saveFavorite(movie: Movie) -> AnyPublisher<Movie, Error>
	
	/// Retrieves the user's favorite movies.
	/// - Returns: A publisher emitting an array of favorite movies or an error.
	func getFavorites() -> AnyPublisher<[Movie], Error>
	
	/// Deletes a movie from the favorites.
	/// - Parameter movie: The movie to delete from favorites.
	/// - Returns: A publisher emitting the deleted movie or an error.
	func delete(movie: Movie) -> AnyPublisher<Movie, Error>
	
	/// Checks if a movie is marked as a favorite.
	/// - Parameter movie: The movie to check.
	/// - Returns: `true` if the movie is a favorite, otherwise `false`.
	func checkFavoriteStatusBy(movie: Movie) -> Bool
	
	/// Retrieves the image data from the given URL.
	/// - Parameters:
	///   - url: The URL of the image.
	///   - completion: A closure to call when the image data is retrieved.
	func getImageData(url: String, completion: @escaping (Data?) -> Void)
}

/// The concrete implementation of the movie repository.
internal final class MovieRepository {
	/// The networking service for fetching data from the network.
	let network: NetworkingProtocol
	
	/// The persistence service for managing core data.
	let persistence: CoreDataManagerProtocol
	
	/// Initializes the movie repository with networking and persistence services.
	/// - Parameters:
	///   - network: The networking service for fetching data from the network.
	///   - persistence: The persistence service for managing core data.
	init(network: NetworkingProtocol = Networking(),
		 persistence: CoreDataManagerProtocol = CoreDataManager(containerName: "MovieDataModel")
	) {
		self.network = network
		self.persistence = persistence
	}
}


extension MovieRepository: MovieRepositoryProtocol {
	func searchMovies(keyword: String, genre: String, limit: Int) -> AnyPublisher<[Movie], ErrorResponse> {
		let apiRequest = SearchMovieRequest(keyword: keyword, genre: genre, limit: limit)
		let result = network.request(apiRequest)
		return result.asPublisher
	}
	
	func delete(movie: Movie) -> AnyPublisher<Movie, Error> {
		// check if exist
		let predicate = NSPredicate(format: "id == %@", movie.id)
		guard let existingMovie = persistence.fetch(MoviePersistence.self, predicate: predicate).first else { 
			return Future<Movie, Error> { promise in
				promise(.failure(NSError(domain: "Movie not exist", code: -1)))
			}
			.eraseToAnyPublisher()
		}
		
		// then delete
		persistence.delete(existingMovie)
		return Future<Movie, Error> { promise in
			promise(.success(movie))
		}
		.eraseToAnyPublisher()
	}
	
	func saveFavorite(movie: Movie) -> AnyPublisher<Movie, Error> {
		// Check if the movie already exists
		let predicate = NSPredicate(format: "id == %@", movie.id)
		let existingMovies = persistence.fetch(MoviePersistence.self, predicate: predicate)
		guard existingMovies.isEmpty else {
			// Movie already exists, return failure
			return Future<Movie, Error> { promise in
				promise(.failure(NSError(domain: "Movie already exists", code: -1)))
			}
			.eraseToAnyPublisher()
		}
		
		// Movie does not exist, create and save new movie
		guard let moviePersistence: MoviePersistence = persistence.create(MoviePersistence.self) else {
			return Future<Movie, Error> { promise in
				promise(.failure(NSError(domain: "Failure to save", code: -1)))
			}
			.eraseToAnyPublisher()
		}
		
		moviePersistence.id = movie.id
		moviePersistence.title = movie.title
		moviePersistence.desc = movie.description
		moviePersistence.year = movie.year
		moviePersistence.trailer = movie.trailer
		moviePersistence.genre = movie.genre
		moviePersistence.posterPathTiny = movie.poster.tiny
		moviePersistence.posterPathLarge = movie.poster.large
		moviePersistence.imageTiny = movie.poster.imageTiny
		moviePersistence.imageLarge = movie.poster.imageLarge
		moviePersistence.favorited = movie.favorited
		
		persistence.saveContext()
		
		return Future<Movie, Error> { promise in
			promise(.success(movie))
		}
		.eraseToAnyPublisher()
	}

	
	func getFavorites() -> AnyPublisher<[Movie], Error> {
		let movies = persistence.fetch(MoviePersistence.self, predicate: nil).map {
			var poster = Poster(tiny: "", large: "")
			poster.tiny = $0.posterPathTiny ?? ""
			poster.large = $0.posterPathLarge ?? ""
			poster.imageTiny = $0.imageTiny
			poster.imageLarge = $0.imageLarge
			
			return Movie(id: $0.id ?? "", title: $0.title ?? "", description: $0.desc ?? "", year: $0.year ?? "", trailer: $0.trailer ?? "", favorited: $0.favorited, price: $0.price ?? "", genre: $0.genre ?? "", poster: poster)
		}
		
		return Future<[Movie], Error> { promise in
			promise(.success(movies.reversed()))
		}.eraseToAnyPublisher()
	}
	
	func checkFavoriteStatusBy(movie: Movie) -> Bool {
		let predicate = NSPredicate(format: "id == %@", movie.id)
		let existingMovies = persistence.fetch(MoviePersistence.self, predicate: predicate)
		
		guard existingMovies.first != nil else { return false }
		return true
	}
	
	func getImageData(url: String, completion: @escaping (Data?) -> Void) {
		KingfisherManager.shared.retrieveImage(with: URL(string: url)!) { result in
			switch result {
			case .success(let imageResult):
				if let imageData = imageResult.image.pngData() {
					completion(imageData)
				} else {
					completion(nil)
				}
			case .failure:
				completion(nil)
				print("~ FAIL TO RETRIEVE IMAGE")
			}
		}
	}
}
