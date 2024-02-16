//
//  HomeVM.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine
import Networking

internal final class HomeVM {
	private let useCase: HomeUseCaseProtocol
	
	/// Initializes the Home view model with the specified use case.
	///
	/// - Parameter useCase: The use case for handling home-related operations.
	init(useCase: HomeUseCaseProtocol = HomeUseCase()) {
		self.useCase = useCase
	}
	
	/// The possible data source types for the Home module.
	enum DataSourceType: Hashable {
		case favorites(title: String, items: [Movie])
		case lists(title: String, items: [ListDataSourceType])
		case error(HomeErrorType)
	}
	
	/// The possible list data source types for the Home module.
	enum ListDataSourceType: Hashable {
		case content(Movie)
		case shimmer(String = UUID().uuidString)
	}
}

extension HomeVM {
	/// The actions that can be performed in the Home module.
	struct Action {
		var didLoad = PassthroughSubject<Void, Never>()
		var getFavorites = PassthroughSubject<Void, Never>()
		var saveMovieToFavorite = PassthroughSubject<Movie, Never>()
		var deleteMovieFromFavorite = PassthroughSubject<Movie, Never>()
		var getMovies = PassthroughSubject<Void, Never>()
		var columnButtonDidTap = PassthroughSubject<Void, Never>()
		var movieTapped = PassthroughSubject<SectionTap, Never>()
		var searchDidCancel = PassthroughSubject<Void, Never>()
		var searchDidChange = PassthroughSubject<String, Never>()
		var movieCompletionHandler = PassthroughSubject<Movie, Never>()
		var showLoading = PassthroughSubject<Bool, Never>()
	}
	
	/// The state of the Home module.
	class State {
		/// The data sources for the Home module.
		@Published var dataSources: [DataSourceType] = []
		
		/// The currently selected genre.
		var genre: String = "comedy"
		
		/// The keyword used for searching.
		@Published var keyword: String = ""
		
		/// The limit for movies.
		var limit: Int = 20
	}
	
	/// Transforms actions into state changes.
	///
	/// - Parameters:
	///   - action: The action to perform.
	///   - cancellables: The bag to store cancellable subscriptions.
	/// - Returns: The state of the Home module.
	func transform(_ action: Action, _ cancellables: CancelBag) -> State {
		let state = State()
		
		// Triggers when the view is loaded. Fetches favorites and movies.
		action.didLoad
			.sink { _ in
				action.getFavorites.send(())
				action.getMovies.send(())
			}
			.store(in: cancellables)
		
		// Shows or hides loading indicator based on the input.
		action.showLoading
			.sink { isLoading in
				
				// Function to generate shimmer items
				func items() -> [ListDataSourceType] {
					[
						.shimmer(),
						.shimmer(),
						.shimmer(),
						.shimmer(),
						.shimmer(),
						.shimmer(),
						.shimmer(),
						.shimmer(),
					]
				}
				
				// Update data sources based on loading state
				if isLoading {
					if let favIndex = state.dataSources.firstIndex(where: {
						if case .favorites = $0 { return true }
						return false
					}) {
						if !state.keyword.isEmpty {
							state.dataSources = []
						}
					}
					
					if let listIndex = state.dataSources.firstIndex(where: {
						if case .lists = $0 { return true }
						return false
					}) {
						if case var .lists(title, _) = state.dataSources[listIndex] {
							state.dataSources[listIndex] = .lists(title: "Top Results", items: items())
						}
					} else {
						state.dataSources = [
							.lists(title: "Top Results", items: items())
						]
					}
				} else {
					if let listIndex = state.dataSources.firstIndex(where: {
						if case .lists = $0 { return true }
						return false
					}) {
						if case var .lists(title, _) = state.dataSources[listIndex] {
							state.dataSources[listIndex] = .lists(title: title, items: [])
						}
					}
				}
			}
			.store(in: cancellables)
		
		// Triggers fetching of movies from the API.
		action.getMovies
			.receive(on: DispatchQueue.global())
			.map {
				action.showLoading.send(true)
			}
			.flatMap {
				self.useCase.searchMovies(keyword: state.keyword, genre: state.genre, limit: state.limit)
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { [weak self] result in
				action.showLoading.send(false)
				guard let self = self else { return }
				
				if case let .failure(error) = result {
					if error.type == .noInternet {
						state.dataSources = [.error(.noInternet)]
					}
				}
				
				if case let .success(movies) = result {
					if let favoriteIndex = state.dataSources.firstIndex(where: { type in
						if case .favorites = type { return true }
						return false
					}) {
						if !state.keyword.isEmpty {
							state.dataSources.remove(at: favoriteIndex)
						} else if case let .favorites(title, _) = state.dataSources[favoriteIndex] {
							state.dataSources[favoriteIndex] = .favorites(title: title, items: self.useCase.savedMovies)
						}
						/// insert favorite section if nil
					} else if state.keyword.isEmpty, !self.useCase.savedMovies.isEmpty {
						state.dataSources.insert(.favorites(title: "Movie you liked", items: self.useCase.savedMovies), at: 0)
					}
					
					/// if movie empty, show not found
					guard !movies.isEmpty else {
						state.dataSources = [.error(.notFound(state.keyword))]
						return
					}
					
					/// remove error section if exist
					state.dataSources.removeAll(where: {
						if case .error = $0 { return true }
						return false
					})
					
					// add movies section when emtpy
					guard state.dataSources.contains(where: { type in
						if case .lists = type { return true }
						return false
					}) else {
						let title = state.keyword.isEmpty ? state.genre : "Top Results"
						state.dataSources.append(.lists(title: title, items: movies.map { .content($0) }))
						return
					}
					
					/// casting the list and change add result
					if let listIndex = state.dataSources.firstIndex(where: { type in
						if case .lists = type { return true }
						return false
					}) {
						
						if case .lists = state.dataSources[listIndex] {
							let title = state.keyword.isEmpty ? state.genre.capitalized : "Top Results"
							state.dataSources[listIndex] = .lists(title: title, items: movies.map { .content($0) })
						}
					}
				}
			}
			.store(in: cancellables)
		
		/// Subscribes to the action of fetching favorite movies.
		action.getFavorites
			.receive(on: DispatchQueue.global())
			.flatMap {
				self.useCase.getFavorites()
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { result in
				if case .failure = result {
					
				}
				
				// If the favorites are successfully fetched, updates the state with the latest favorites.
				if case let .success(movies) = result {
					if let index = state.dataSources.firstIndex(where: { type in
						if case .favorites = type { return true }
						return false
					}) {
						// If the favorite section exists, updates its items with the latest favorites.
						guard !movies.isEmpty else {
							// If there are no favorites, removes the favorite section.
							state.dataSources.remove(at: index)
							return
						}
						
						// Updates the favorite section with the latest favorites.
						if case let .favorites(title, _) = state.dataSources[index] {
							state.dataSources[index] = .favorites(title: title, items: movies)
						}
						
					} else if state.keyword.isEmpty, !movies.isEmpty {
						// If there is no favorite section and there are favorites, inserts a new favorite section at the beginning.
						state.dataSources.insert(.favorites(title: "Movie you liked", items: movies), at: 0)
						
					} else if state.keyword.isEmpty, movies.isEmpty, !Reachability.isConnectedToNetwork() {
						// If there is no favorite and no internet connection, shows an error.
						state.dataSources = [.error(.noInternet)]
					}
				}
			}
			.store(in: cancellables)
		
		/// Subscribes to the action of handling movie detail completion.
		action.movieCompletionHandler
			.sink { movie in
				// If the movie is favorited, adds it to favorites and shows a toast. Otherwise, removes it from favorites and shows a toast.
				if movie.favorited {
					Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Removed from favorite")))
					action.deleteMovieFromFavorite.send(movie)
				} else {
					Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Added to favorite")))
					action.saveMovieToFavorite.send(movie)
				}
			}
			.store(in: cancellables)
		
		/// Subscribes to the action of handling movie taps.
		action.movieTapped
			.sink { [weak self] section in
				guard let self = self else { return }
				
				if case let .list(tap, hashValue) = section {
					// Handles movie taps based on the section and tap type.
					guard let listIndex = state.dataSources.firstIndex(where: { type in
						if case .lists = type { return true }; return false
					}), 
					case let .lists(_, items) = state.dataSources[listIndex],
						  let movieIndex = items.firstIndex(where: {
							  if case let .content(movie) = $0, movie.hashValue == hashValue { return true}
							  return false
						  })
					else { return }
					
					guard case let .content(movie) = items[movieIndex] else { return }
					let isFavorited = self.useCase.checkFavoriteStatusBy(movie: movie)
					
					if case .double = tap {
						// Handles double taps - adds or removes from favorites based on current status.
						if !isFavorited {
							// save to local
							Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Added to favorite")))
							action.saveMovieToFavorite.send(movie)
						} else {
							// delete on local
							Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Removed from favorite")))
							action.deleteMovieFromFavorite.send(movie)
						}
					}
					
					if case .single = tap {
						// Handles single taps - opens movie detail screen.
						Atlas.route(to: .detail(movie: movie, favoriteCompletion: { movie in
							action.movieCompletionHandler.send(movie)
						}))
					}
				}
				
				if case let .favorite(tap, hashValue) = section {
					// Handles taps on favorite items.
					guard let favoriteIndex = state.dataSources.firstIndex(where: { type in
						if case .favorites = type { return true }; return false
					}),
							case let .favorites(_, items) = state.dataSources[favoriteIndex],
						  let movieIndex = items.firstIndex(where: { $0.hashValue == hashValue })
					else { return }
					
					var movie = items[movieIndex]
					
					if case .single = tap {
						// Handles single taps - opens movie detail screen.
						Atlas.route(to: .detail(movie: movie, favoriteCompletion: { movie in
							action.movieCompletionHandler.send(movie)
						}))
					}
				}
			}
			.store(in: cancellables)
		
		/// Subscribes to the action of saving a movie to favorites.
		action.saveMovieToFavorite
			.receive(on: DispatchQueue.global())
			.flatMap {
				var movie = $0
				movie.favorited = true
				return self.useCase.saveFavorite(movie: movie)
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { result in
				// If the movie is successfully saved to favorites, fetches favorites again to update the UI.
				if case let.success(movie) = result {
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
		
		/// Subscribes to the action of deleting a movie from favorites.
		action.deleteMovieFromFavorite
			.receive(on: DispatchQueue.global())
			.flatMap {
				var movie = $0
				movie.favorited = false
				return self.useCase.delete(movie: movie)
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { result in
				if case let .failure(error) = result {
					print(error)
				}
				// If the movie is successfully deleted from favorites
				if case let .success(movie) = result {
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
			
		/// Subscribes to the action of handling search text changes.
		action.searchDidChange
			.sink { text in
				// Updates the search keyword and triggers fetching of movies based on the new keyword.
				if !text.isEmpty {
					state.genre = ""
				} else {
					action.getFavorites.send(())
					state.genre = "comedy"
				}
				state.keyword = text
				action.getMovies.send(())
			}
			.store(in: cancellables)
		
		return state
	}
}
