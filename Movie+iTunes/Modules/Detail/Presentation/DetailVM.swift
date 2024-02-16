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
	
	init(useCase: DetailUseCaseProtocol = DetailUseCase(), movie: Movie? = nil, favoriteCompletion: ((Movie) -> Void)? = nil) {
		self.useCase = useCase
		self.movie = movie
		self.favoriteCompletion = favoriteCompletion
	}
	
	enum DataSourceType: Hashable {
		case header(Movie)
		case trailers(Movie)
	}
	
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
	
	func transform(_ action: Action, cancellables: CancelBag) -> State {
		let state = State()
		var movie = movie!
		
		movie.favorited = self.useCase.checkFavoriteStatusBy(movie: movie)
		state.dataSources = [
			.header(movie),
			.trailers(movie),
		]
		state.poster = movie.poster
		
		action.buttonDidTap
			.map {
				movie.favorited = self.useCase.checkFavoriteStatusBy(movie: movie)
				return $0
			}
			.sink { [weak self] type in
				guard let self = self else { return }
				if case .favorite = type {
					self.favoriteCompletion?(movie)
				}
			}
			.store(in: cancellables)
		
		
		return state
	}
}
