//
//  AlertVC.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 13/02/24.
//

import UIKit
import PanModal

class AlertViewController: UIViewController, PanModalPresentable {
	
	private let alertViewHeight: CGFloat = 68
	private weak var timer: Timer?
	private var countdown: Int = 5
	
	let alertView: AlertView = {
		let alertView = AlertView()
		alertView.layer.cornerRadius = 10
		return alertView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	private func startTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			if self?.countdown == 0 {
				self?.invalidateTimer()
				self?.dismiss(animated: true, completion: nil)
				return
			}
			self?.countdown -= 1
		}
	}
	
	func invalidateTimer() {
		timer?.invalidate()
	}
	
	deinit {
		invalidateTimer()
	}
	
	private func setupView() {
		view.addSubview(alertView)
		alertView.translatesAutoresizingMaskIntoConstraints = false
		alertView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
		alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
		alertView.heightAnchor.constraint(equalToConstant: alertViewHeight).isActive = true
	}
	
	// MARK: - PanModalPresentable
	
	var panScrollable: UIScrollView? {
		return nil
	}
	
	var shortFormHeight: PanModalHeight {
		return .contentHeight(alertViewHeight)
	}
	
	var longFormHeight: PanModalHeight {
		return shortFormHeight
	}
	
	var isUserInteractionEnabled: Bool {
		return true
	}
	
	var showDragIndicator: Bool {
		return false
	}
	
	var anchorModalToLongForm: Bool {
		return true
	}
	
	var panModalBackgroundColor: UIColor {
		return .clear
	}
}

