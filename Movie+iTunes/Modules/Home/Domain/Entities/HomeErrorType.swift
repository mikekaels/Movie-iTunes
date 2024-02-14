//
//  HomeErrorType.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 14/02/24.
//

import Foundation

enum HomeErrorType: Hashable {
	case noInternet
	case notFound(String)
	
	var image: String {
		switch self {
		case .noInternet: return "no_internet"
		case .notFound: return "not_found"
		}
	}
	
	var title: String {
		switch self {
		case .noInternet: return "No internet"
		case .notFound: return "Not found"
		}
	}
	
	var desc: String {
		switch self {
		case .noInternet: return "Check your connection or try again"
		case let .notFound(title): return "Sorry, we couldn't find movie with title \"\(title)\""
		}
	}
	
	var buttonTitle: String? {
		switch self {
		case .noInternet: return "Try again"
		case .notFound: return nil
		}
	}
}
