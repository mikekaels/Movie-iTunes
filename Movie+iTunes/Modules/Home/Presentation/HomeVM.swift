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
		case lists(title: String, items: [Movie], column: ColumnType)
	}
	
	enum ColumnType {
		case two
		case three
		
		var intValue: Int {
			switch self {
			case .two: return 2
			case .three: return 3
			}
		}
		
		var icon: String {
			switch self {
			case .two: return "rectangle.split.2x2"
			case .three: return "rectangle.split.3x3"
			}
		}
		
		var height: Float {
			switch self {
			case .two: return 300
			case .three: return 180
			}
		}
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
		var movieDoubleTap = PassthroughSubject<Int, Never>()
		var searchDidCancel = PassthroughSubject<Void, Never>()
		var searchDidChange = PassthroughSubject<String, Never>()
	}
	
	class State {
		@Published var dataSources: [DataSourceType] = [
			.favorites(title: "Movie you liked", items: []),
			.lists(title: "Movies", items: [], column: .two)
		]
		
		// inital genre
		var genre: String = "anime"
		
		// inital search keyword
		var keyword: String = ""
		
		// limit movies
		var limit: Int = 20
		
		// default column is 2
		var column: ColumnType = .two
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
			.sink { result in
				if case let .failure(error) = result {
					print(error)
				}
				
				if case let .success(movies) = result {
					guard let index = state.dataSources.firstIndex(where: { type in
						if case .lists = type { return true }
						return false
					}) else { return }
					// casting the list and change the value
					if case let .lists(title, _, column) = state.dataSources[index] {
						state.dataSources[index] = .lists(title: title, items: movies, column: column)
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
				if case let .failure(error) = result {
					
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
					} else if !movies.isEmpty {
						state.dataSources.insert(.favorites(title: "Movie you liked", items: movies), at: 0)
					}
				}
			}
			.store(in: cancellables)
		
		action.columnButtonDidTap
			.sink { _ in
				
				// change the column
				if state.column == .three {
					state.column = .two
				} else if state.column == .two {
					state.column = .three
				}
				
				// Get index of list
				guard let index = state.dataSources.firstIndex(where: { type in
					if case .lists = type { return true }
					return false
				}) else { return }
				// casting the list and change the value
				if case let .lists(title, items, _) = state.dataSources[index] {
					state.dataSources[index] = .lists(title: title, items: items, column: state.column)
				}
			}
			.store(in: cancellables)
		
		action.movieDoubleTap
			.sink { hashValue in
				print(hashValue)
				guard let listIndex = state.dataSources.firstIndex(where: { type in
					if case .lists = type { return true }; return false
					}) 
				else { return }
				
				guard case var .lists(title, items, column) = state.dataSources[listIndex] else { return }
				
				guard let movieIndex = items.firstIndex(where: { $0.hashValue == hashValue }) else { return }
				
				
				var movie = items[movieIndex]
				movie.favorited.toggle()
				
				// change data on datasource
				items[movieIndex] = movie
				state.dataSources[listIndex] = .lists(title: title, items: items, column: column)
				
				if movie.favorited {
					// save to local
					action.saveMovieToFavorite.send(movie)
				} else {
					// save to local
					action.deleteMovieFromFavorite.send(movie)
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
					print("~ Success saving movie to favorite")
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
					print("~ Success delete movie to favorite")
					action.getFavorites.send(())
				}
			}
			.store(in: cancellables)
			
		action.searchDidChange
			.sink { text in
				if !text.isEmpty {
					state.genre = ""
				} else {
					state.genre = "anime"
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
