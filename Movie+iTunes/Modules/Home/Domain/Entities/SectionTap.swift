//
//  SectionTap.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 14/02/24.
//

import Foundation

enum SectionTap {
	case favorite(Tap, Int?)
	case list(Tap, Int?)
	
	enum Tap {
		case single
		case double
	}
}

