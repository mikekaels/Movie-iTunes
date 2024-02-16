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
	
	init(useCase: HomeUseCaseProtocol = HomeUseCase()) {
		self.useCase = useCase
	}
	
	enum DataSourceType: Hashable {
		case favorites(title: String, items: [Movie])
		case lists(title: String, items: [ListDataSourceType])
		case error(HomeErrorType)
	}
	
	enum ListDataSourceType: Hashable {
		case content(Movie)
		case shimmer(String = UUID().uuidString)
	}
}

extension HomeVM {
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
	
	class State {
		@Published var dataSources: [DataSourceType] = []
		
		// inital genre
		var genre: String = "comedy"
		
		// inital search keyword
		@Published var keyword: String = ""
		
		// limit movies
		var limit: Int = 20
	}
	
	func transform(_ action: Action, _ cancellables: CancelBag) -> State {
		let state = State()
		
		action.didLoad
			.sink { _ in
				action.getFavorites.send(())
				action.getMovies.send(())
			}
			.store(in: cancellables)
		
		action.showLoading
			.sink { isLoading in
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
				
				if case let .success(movies) = result {
					if let index = state.dataSources.firstIndex(where: { type in
						if case .favorites = type { return true }
						return false
					}) {
						// if favorite is empty, remove favorite section
						guard !movies.isEmpty else {
							state.dataSources.remove(at: index)
							return
						}
						
						// casting the favorite and change the value
						if case let .favorites(title, _) = state.dataSources[index] {
							state.dataSources[index] = .favorites(title: title, items: movies)
						}
					} else if state.keyword.isEmpty, !movies.isEmpty {
						state.dataSources.insert(.favorites(title: "Movie you liked", items: movies), at: 0)
					} else if state.keyword.isEmpty, movies.isEmpty, !Reachability.isConnectedToNetwork() {
						state.dataSources = [.error(.noInternet)]
					}
				}
			}
			.store(in: cancellables)
		
		action.movieCompletionHandler
			.sink { movie in
				if movie.favorited {
					Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Removed from favorite")))
					action.deleteMovieFromFavorite.send(movie)
				} else {
					Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Added to favorite")))
					action.saveMovieToFavorite.send(movie)
				}
			}
			.store(in: cancellables)
		
		action.movieTapped
			.sink { [weak self] section in
				guard let self = self else { return }
				if case let .list(tap, hashValue) = section {
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
						Atlas.route(to: .detail(movie: movie, favoriteCompletion: { movie in
							action.movieCompletionHandler.send(movie)
						}))
					}
				}
				
				if case let .favorite(tap, hashValue) = section {
					guard let favoriteIndex = state.dataSources.firstIndex(where: { type in
						if case .favorites = type { return true }; return false
					}),
							case let .favorites(_, items) = state.dataSources[favoriteIndex],
						  let movieIndex = items.firstIndex(where: { $0.hashValue == hashValue })
					else { return }
					
					var movie = items[movieIndex]
					
					if case .single = tap {
						Atlas.route(to: .detail(movie: movie, favoriteCompletion: { movie in
							action.movieCompletionHandler.send(movie)
						}))
					}
				}
			}
			.store(in: cancellables)
		
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
				if case let.success(movie) = result {
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
		
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
				
				if case let .success(movie) = result {
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
			
		action.searchDidChange
			.sink { text in
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
		
		action.searchDidCancel
			.sink { _ in
				
			}
			.store(in: cancellables)
		
		return state
	}
}
