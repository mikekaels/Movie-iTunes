//
//  DetailVM.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine

final class DetailVM {
	let useCase: DetailUseCaseProtocol
	var movie: Movie?
	let favoriteCompletion: ((Movie) -> Void)?
	
	/// Initializes the detail view model.
	/// - Parameters:
	///   - useCase: The use case providing functionality for movie details.
	///   - movie: The movie being displayed.
	///   - favoriteCompletion: A closure to be called when the favorite status of the movie is updated.
	init(useCase: DetailUseCaseProtocol = DetailUseCase(), movie: Movie? = nil, favoriteCompletion: ((Movie) -> Void)? = nil) {
		self.useCase = useCase
		self.movie = movie
		self.favoriteCompletion = favoriteCompletion
	}
	
	/// The type of data sources for the detail view.
	enum DataSourceType: Hashable {
		case header(Movie)
		case trailers(Movie)
	}
	
	/// The type of buttons available in the detail view.
	enum ButtonType {
		case buy
		case favorite
	}
}

extension DetailVM {
	struct Action {
		var buttonDidTap = PassthroughSubject<ButtonType, Never>()
	}
	
	class State {
		@Published var dataSources: [DataSourceType] = []
		
		@Published var poster: Poster? = nil
	}
	
	/// Transforms incoming actions into the state of the detail view.
	/// - Parameters:
	///   - action: The incoming actions.
	///   - cancellables: The cancel bag for managing subscriptions.
	/// - Returns: The state of the detail view.
	func transform(_ action: Action, cancellables: CancelBag) -> State {
		let state = State()
		guard var movie = movie else { return state }
		
		// Update the favorite status of the movie
		movie.favorited = self.useCase.checkFavoriteStatusBy(movie: movie)
		
		state.dataSources = [
			.header(movie),
			.trailers(movie),
		]
		
		state.poster = movie.poster
		
		// Subscribe to button tap events
		action.buttonDidTap
			.map {
				// Update the favorite status of the movie when the favorite button is tapped
				movie.favorited = self.useCase.checkFavoriteStatusBy(movie: movie)
				return $0
			}
			.sink { [weak self] type in
				guard let self = self else { return }
				if case .favorite = type {
					// Call the favorite completion closure when the favorite button is tapped
					self.favoriteCompletion?(movie)
				}
			}
			.store(in: cancellables)
		
		return state
	}
}
