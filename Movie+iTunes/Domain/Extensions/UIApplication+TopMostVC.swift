//
//  UIApplication+TopMostVC.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 13/02/24.
//

import UIKit

extension UIApplication {
	public static func topMostViewController() -> UIViewController? {
		return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.topMostViewController()
	}
	
	public static func topMostTabBarViewController() -> UIViewController? {
		return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.topMostTabBarViewController()
	}
}

extension UIViewController {
	public func topMostViewController() -> UIViewController {
		
		if let presented = self.presentedViewController {
			return presented.topMostViewController()
		}
		
		if let navigation = self as? UINavigationController {
			return navigation.visibleViewController?.topMostViewController() ?? navigation
		}
		
		if let tab = self as? UITabBarController {
			return tab.selectedViewController?.topMostViewController() ?? tab
		}
		
		return self
	}
	
	public func topMostTabBarViewController() -> UIViewController {
		
		if let navigation = self as? UINavigationController {
			return navigation.visibleViewController?.topMostTabBarViewController() ?? navigation
		}
		
		return self
	}
}

