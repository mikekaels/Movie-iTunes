//
//  Atlas.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 13/02/24.
//

/// An internal class responsible for routing within the Atlas framework.
internal class Atlas {
	/// A static router closure used for routing within the framework.
	internal static var router: ((Route) -> Void)?
	
	/// Routes to the specified destination.
	///
	/// - Parameter to: The destination to route to.
	internal static func route(to: Route) {
		if let router = Atlas.router {
			router(to)
		}
	}
}

/// An enumeration representing various routes within the Atlas framework.
internal enum Route {
	/// Represents a detail route, typically for displaying movie details.
	case detail(movie: Movie, favoriteCompletion: ((Movie) -> Void)?)
	/// Represents a component route, used for displaying various UI components.
	case component(Component)
	
	/// An enumeration representing different types of UI components.
	enum Component {
		/// Represents a toast component.
		case toast(image: String, title: String, description: String)
	}
}
