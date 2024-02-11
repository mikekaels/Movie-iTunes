//
//  NSObject+Identifier.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Foundation

extension NSObject {
	public var identifier: String {
		String(describing: type(of: self))
	}
	
	public static var identifier: String {
		String(describing: self)
	}
}
