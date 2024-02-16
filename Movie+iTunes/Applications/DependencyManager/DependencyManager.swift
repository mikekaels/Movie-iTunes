//
//  DependencyManager.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import IQKeyboardManagerSwift

internal enum DependencyManager {
	@MainActor static func setup() {
		AtlasDependencyManager.setup()
		IQKeyboardManager.shared.enable = true
//		IQKeyboardManager.shared.resignOnTouchOutside = true
	}
}
