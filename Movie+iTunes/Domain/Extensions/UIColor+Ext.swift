//
//  UIColor+Ext.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit

extension UIColor {
	
	internal enum ThemeType: String {
		case background = "1E1C1C"
	}
	
	internal static func theme(_ type: ThemeType) -> UIColor {
		return UIColor(hex: type.rawValue)
	}
	
	internal convenience init(light: UIColor, dark: UIColor) {
		if #available(iOS 13.0, *) {
			self.init { (traitCollection) -> UIColor in
				traitCollection.userInterfaceStyle == .dark ? light : light
			}
		} else {
			self.init(cgColor: light.cgColor)
		}
	}
	
	public convenience init(hex: String) {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 1
		
		let hexColor = hex.replacingOccurrences(of: "#", with: "")
		let scanner = Scanner(string: hexColor)
		var hexNumber: UInt64 = 0
		var valid = false
		
		if scanner.scanHexInt64(&hexNumber) {
			if hexColor.count == 8 {
				r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
				g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
				b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
				a = CGFloat(hexNumber & 0x000000ff) / 255
				valid = true
			}
			else if hexColor.count == 6 {
				r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
				g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
				b = CGFloat(hexNumber & 0x0000ff) / 255
				valid = true
			}
		}
		
#if DEBUG
		assert(valid, "UIColor initialized with invalid hex string")
#endif
		
		self.init(red: r, green: g, blue: b, alpha: a)
	}
}


extension UIColor {
	/// blue-0 - F2F7FD
	public static let blue0 =
	UIColor(light: UIColor(hex: "F2F7FD"), dark: UIColor(hex: "F2F7FD"))
}


