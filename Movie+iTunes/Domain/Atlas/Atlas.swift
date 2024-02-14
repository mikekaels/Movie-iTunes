//
//  Atlas.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 13/02/24.
//

internal class Atlas {
	internal static var router: ((Route) -> Void)?
	
	internal static func route(to: Route) {
		if let router = Atlas.router {
			router(to)
		}
	}
}

internal enum Route {
	case detail(Movie)
	case component(Component)
	
	enum Component {
		case toast(image: String, title: String, description: String)
	}
}
