//
//  Reachability.swift
//  Networking
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation
import SystemConfiguration

/// A utility enum for checking network reachability.
public enum Reachability {
	/// Checks if the device is connected to a network.
	///
	/// - Returns: `true` if the device is connected to a network, otherwise `false`.
	public static func isConnectedToNetwork() -> Bool {
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				SCNetworkReachabilityCreateWithAddress(nil, $0)
			}
		}) else {
			return false
		}
		
		var flags: SCNetworkReachabilityFlags = []
		if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
			return false
		}
		
		let isReachable = flags.contains(.reachable)
		let needsConnection = flags.contains(.connectionRequired)
		
		return isReachable && !needsConnection
	}
}

