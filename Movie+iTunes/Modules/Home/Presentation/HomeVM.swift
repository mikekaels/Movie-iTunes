//
//  HomeVM.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine
import Foundation

internal final class HomeVM {
	private let useCase: HomeUseCaseProtocol
	
	init(useCase: HomeUseCaseProtocol = HomeUseCase()) {
		self.useCase = useCase
	}
	
	enum DataSourceType: Hashable {
		case favorites(title: String, items: [Movie])
		case lists(title: String, items: [Movie])
		case error(HomeErrorType)
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
	}
	
	class State {
		@Published var dataSources: [DataSourceType] = [
			.favorites(title: "Movie you liked", items: []),
			.lists(title: "Movies", items: [])
		]
		
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
		
		action.getMovies
			.receive(on: DispatchQueue.global())
			.flatMap {
				self.useCase.searchMovies(keyword: state.keyword, genre: state.genre, limit: state.limit)
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { [weak self] result in
				guard let self = self else { return }
				
				if case let .failure(error) = result {
					print(error)
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
						state.dataSources.append(.lists(title: title, items: movies))
						return
					}
					
					/// casting the list and change add result
					if let listIndex = state.dataSources.firstIndex(where: { type in
						if case .lists = type { return true }
						return false
					}) {
						
						if case .lists = state.dataSources[listIndex] {
							let title = state.keyword.isEmpty ? state.genre.capitalized : "Top Results"
							state.dataSources[listIndex] = .lists(title: title, items: movies)
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
					}
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
					let movieIndex = items.firstIndex(where: { $0.hashValue == hashValue })
					else { return }
					
					let movie = items[movieIndex]
					let isFavorited = self.useCase.checkFavoriteStatusBy(movie: movie)
					
					if case .double = tap {
						if !isFavorited {
							// save to local
							action.saveMovieToFavorite.send(movie)
							Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Added to favorite")))
						} else {
							// delete on local
							action.deleteMovieFromFavorite.send(movie)
							Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Removed from favorite")))
						}
					}
					
					if case .single = tap {
						Atlas.route(to: .detail(movie))
					}
				}
				
				if case let .favorite(tap, hashValue) = section {
					guard let listIndex = state.dataSources.firstIndex(where: { type in
						if case .favorites = type { return true }; return false
					}),
							case let .favorites(_, items) = state.dataSources[listIndex],
						  let movieIndex = items.firstIndex(where: { $0.hashValue == hashValue })
					else { return }
					
					var movie = items[movieIndex]
					
					if case .double = tap {
						movie.favorited.toggle()
						action.deleteMovieFromFavorite.send(movie)
						Atlas.route(to: .component(.toast(image: movie.poster.tiny, title: movie.title, description: "Removed from favorite")))
					}
					
					if case .single = tap {
						Atlas.route(to: .detail(movie))
					}
				}
			}
			.store(in: cancellables)
		
		action.saveMovieToFavorite
			.receive(on: DispatchQueue.global())
			.flatMap {
				self.useCase.saveFavorite(movie: $0)
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { result in
				if case .success = result {
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
		
		action.deleteMovieFromFavorite
			.receive(on: DispatchQueue.global())
			.flatMap {
				self.useCase.delete(movie: $0)
					.map { Result.success($0) }
					.catch { Just(Result.failure($0)) }
					.eraseToAnyPublisher()
			}
			.sink { result in
				if case let .failure(error) = result {
					print(error)
				}
				
				if case .success = result {
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
			
		action.searchDidChange
			.sink { text in
				if !text.isEmpty {
					state.genre = ""
				} else {
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
