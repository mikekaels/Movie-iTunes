//
//  AtlasDependencyManager.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import PanModal

internal enum AtlasDependencyManager {
	static func setup() {
		Atlas.router = { route in
			DispatchQueue.main.async {
				guard let topVC = UIApplication.topMostViewController() else { return }
				
				if case let .component(type) = route, case let .toast(image, title, desc) = type {
					let vc = Toast(image: image, title: title, description: desc)
					topVC.presentPanModal(vc)
				}
				
				if case let .detail(movie) = route {
					let vm = DetailVM(movie: movie)
					let vc = DetailVC(viewModel: vm)
					topVC.navigationController?.pushViewController(vc, animated: true)
				}
			}
		}
	}
}
