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

internal protocol MovieRepositoryProtocol {
	func searchMovies(keyword: String, genre: String, limit: Int) -> AnyPublisher<[Movie], ErrorResponse>
	func saveFavorite(movie: Movie) -> AnyPublisher<Void, Error>
	func getFavorites() -> AnyPublisher<[Movie], Error>
	func delete(movie: Movie) -> AnyPublisher<Void, Error>
	func checkFavoriteStatusBy(movie: Movie) -> Bool
	func getImageData(url: String, completion: @escaping (Data?) -> Void)
}

internal final class MovieRepository {
	let network: NetworkingProtocol
	let persistence: CoreDataManagerProtocol
	
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
	
	func delete(movie: Movie) -> AnyPublisher<Void, Error> {
		// check if exist
		let predicate = NSPredicate(format: "id == %@", movie.id)
		guard let existingMovie = persistence.fetch(MoviePersistence.self, predicate: predicate).first else { 
			return Future<Void, Error> { promise in
				promise(.failure(NSError(domain: "Movie not exist", code: -1)))
			}
			.eraseToAnyPublisher()
		}
		
		// then delete
		persistence.delete(existingMovie)
		return Future<Void, Error> { promise in
			promise(.success(()))
		}
		.eraseToAnyPublisher()
	}
	
	func saveFavorite(movie: Movie) -> AnyPublisher<Void, Error> {
		// Check if the movie already exists
		let predicate = NSPredicate(format: "id == %@", movie.id)
		let existingMovies = persistence.fetch(MoviePersistence.self, predicate: predicate)
		guard existingMovies.isEmpty else {
			// Movie already exists, return failure
			return Future<Void, Error> { promise in
				promise(.failure(NSError(domain: "Movie already exists", code: -1)))
			}
			.eraseToAnyPublisher()
		}
		
		// Movie does not exist, create and save new movie
		guard let moviePersistence: MoviePersistence = persistence.create(MoviePersistence.self) else {
			return Future<Void, Error> { promise in
				promise(.failure(NSError(domain: "Failure to save", code: -1)))
			}
			.eraseToAnyPublisher()
		}
		
		moviePersistence.id = movie.id
		moviePersistence.title = movie.title
		moviePersistence.desc = movie.description
		moviePersistence.year = movie.year
		moviePersistence.trailer = movie.trailer
		moviePersistence.posterPath = movie.posterPath
		moviePersistence.image = movie.image
		moviePersistence.favorited = movie.favorited
		
		persistence.saveContext()
		
		return Future<Void, Error> { promise in
			promise(.success(()))
		}
		.eraseToAnyPublisher()
	}

	
	func getFavorites() -> AnyPublisher<[Movie], Error> {
		let movies = persistence.fetch(MoviePersistence.self, predicate: nil).map {
			Movie(id: $0.id ?? "", title: $0.title ?? "", description: $0.desc ?? "", year: $0.year ?? "", trailer: $0.trailer ?? "", posterPath: $0.posterPath ?? "", image: $0.image, favorited: $0.favorited, price: $0.price ?? "", genre: $0.genre ?? "")
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
