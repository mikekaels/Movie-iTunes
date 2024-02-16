//
//  NetworkResult.swift
//  Networking
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation
import Combine

/// An enumeration representing various types of network errors.
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

/// A structure representing an error response from a network request.
public struct ErrorResponse: Error {
	public let type: NetworkErrorType
	public let message: String
	public let code: Int
}

// An enumeration representing the result of a network operation.
public enum NetworkResult<T> {
	case success(T)
	case failure(ErrorResponse)
	
	/// Converts the network result into a Combine publisher.
	///
	/// - Returns: A publisher that emits either the success data or the failure error response.
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


