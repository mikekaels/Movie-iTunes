//
//  HomeVM.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine

internal final class HomeVM {
	private let useCase: HomeUseCaseProtocol
	
	init(useCase: HomeUseCaseProtocol = HomeUseCase()) {
		self.useCase = useCase
	}
	
	enum DataSourceType: Hashable {
		case favorites(title: String, items: [Movie])
		case lists(title: String, items: [Movie])
	}
}

extension HomeVM {
	struct Action {
		var didLoad = PassthroughSubject<Void, Never>()
		var getFavorites = PassthroughSubject<Void, Never>()
		var getMovies = PassthroughSubject<Void, Never>()
	}
	
	class State {
		@Published var dataSources: [DataSourceType] = []
	}
	
	func transform(_ action: Action, _ cancellables: CancelBag) -> State {
		let state = State()
		
		action.didLoad
			.sink { _ in
				action.getFavorites.send(())
			}
			.store(in: cancellables)
		
		action.getFavorites
			.sink { [weak self] _ in
				guard let self = self else { return }
				let fav = self.useCase.getFavorites()
				state.dataSources = [
					.favorites(title: "Movie you liked", items: fav),
					.lists(title: "Popular now", items: fav)
				]
			}
			.store(in: cancellables)
		
		return state
	}
}
