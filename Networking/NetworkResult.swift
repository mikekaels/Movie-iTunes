//
//  NetworkResult.swift
//  Networking
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation
import Combine

public enum NetworkErrorType: Error {
	case noInternet
	case resError
	case invalidResponse
	case noData
	case serializationError
	case failedResponse
	case refreshTokenFailed
	case cancelled
}

public struct ErrorResponse: Error {
	public let type: NetworkErrorType
	public let message: String
	public let code: Int
}

public enum NetworkResult<T> {
	case success(T)
	case failure(ErrorResponse)
	
	public var asPublisher: AnyPublisher<T, ErrorResponse> {
		Future { resolve in
			switch self {
			case let .success(data):
				resolve(.success(data))
			case let .failure(error):
				resolve(.failure(error))
			}
		}
		.eraseToAnyPublisher()
	}
}


