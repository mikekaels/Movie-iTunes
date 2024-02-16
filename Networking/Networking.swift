//
//  Networking.swift
//  Networking
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation

/// A protocol defining networking capabilities.
public protocol NetworkingProtocol {
	/// Performs a network request.
	///
	/// - Parameter request: The request to be executed.
	/// - Returns: The result of the network request.
	func request<T: APIRequest>(_ request: T) -> NetworkResult<T.Response>
}

/// A class responsible for handling network operations.
public final class Networking: NSObject {
	/// The URLSession used for networking operations.
	var service: URLSession = .shared
	/// A dictionary containing certificates for secure connections.
	public var certificates: [String: String] = [:]
	
	/// Initializes a new instance of `Networking`.
	public override init() {
		super.init()
		self.service = URLSession(configuration: .default)
	}
}

extension Networking: NetworkingProtocol {
	public func request<T: APIRequest>(_ request: T) -> NetworkResult<T.Response> {
		let semaphore = DispatchSemaphore(value: 0)
		
		var responseResult: NetworkResult<T.Response> = .failure(ErrorResponse(type: .cancelled, message: "Canceled", code: -1000))
		
		guard Reachability.isConnectedToNetwork() else {
			return  .failure(ErrorResponse(type: .noInternet, message: "No internet connection", code: -1003))
		}
		guard let urlRequest = createURLRequest(from: request) else {
			responseResult = .failure(ErrorResponse(type: .invalidResponse, message: "Invalid to create URL Request", code: -1001))
			return responseResult
		}
		
		
		
		let task = service.dataTask(with: urlRequest) { [weak self] data, response, error in
			guard let self = self else { return }
			
			responseResult = self.responseHandler(data: data, response: response, error: error, request: request)
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		return responseResult
	}
	
	private func responseHandler<T: APIRequest>(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		request: T
	) -> NetworkResult<T.Response> {
		
		var responseResult: NetworkResult<T.Response> = .failure(ErrorResponse(type: .invalidResponse, message: "Invalid Response", code: -1003))
		
		guard let data = data else {
			responseResult = .failure(ErrorResponse(type: .noData, message: "No Data Bro", code: -1002))
			return responseResult
		}
		
		guard let response = response as? HTTPURLResponse else {
			return .failure(ErrorResponse(type: .failedResponse, message: "Failed Response", code: -1003))
		}
		
		guard 200..<300 ~= response.statusCode else {
			responseResult = .failure(ErrorResponse(type: .resError, message: response.description, code: response.statusCode))
			return responseResult
		}
		
		do {
			let result = try request.map(data)
			return .success(result)
		} catch {
			return .failure(ErrorResponse(type: .serializationError, message: error.localizedDescription, code: -1006))
		}
	}
	
	private func createURLRequest<T: APIRequest>(from request: T) -> URLRequest? {
		let urlString = request.baseURL + request.path
		
		guard let url = URL(string: urlString) else { return nil }
		
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = request.method.rawValue
		
		setHeaders(to: &urlRequest, with: request)
		
		return urlRequest
	}
	
	private func setHeaders<T: APIRequest> ( to urlRequest: inout URLRequest, with request: T) {
		request.headers.forEach { (key: String, value: Any) in
			urlRequest.addValue("\(value)", forHTTPHeaderField: key)
		}
	}
}


