//
//  APIRequest.swift
//  Networking
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation

/// An enumeration representing HTTP request methods.
public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
}

/// A protocol defining requirements for an API request.
public protocol APIRequest {
	/// The associated response type for the request.
	associatedtype Response
	
	/// The base URL for the API endpoint.
	var baseURL: String { get }
	
	/// The HTTP method for the request.
	var method: HTTPMethod { get }
	
	/// The path to the specific endpoint.
	var path: String { get set }
	
	/// The body parameters for the request.
	var body: [String: Any] { get set }
	
	/// The headers for the request.
	var headers: [String: Any] { get set }
	
	/// Maps the received data to the associated response type.
	///
	/// - Parameter data: The data received from the network.
	/// - Returns: The response object of the associated type.
	/// - Throws: An error if mapping fails.
	func map(_ data: Data) throws -> Response
}


