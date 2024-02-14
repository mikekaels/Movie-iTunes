//
//  Toast.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 13/02/24.
//

import UIKit
import PanModal
import SnapKit
import Kingfisher

class Toast: UIViewController, PanModalPresentable {
	
	private let toastViewHeight: CGFloat = 68
	private weak var timer: Timer?
	private var countdown: Int = 3
	
	private let backgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = .white.withAlphaComponent(0.9)
		view.layer.cornerRadius = 5
		return view
	}()
	
	lazy var contentImageView: UIImageView = {
		let image = UIImageView()
		image.layer.cornerRadius = 6.0
		image.contentMode = .scaleAspectFill
		image.layer.masksToBounds = true
		return image
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .black
		return label
	}()
	
	let message: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .light)
		label.textColor = .black
		return label
	}()
	
	private lazy var toastStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.spacing = 4.0
		return stackView
	}()
	
	init(image: String, title: String, description: String) {
		super.init(nibName: nil, bundle: nil)
		if let url = URL(string: image) {
			contentImageView.kf.setImage(with: url)
		}
		
		titleLabel.text = title
		message.text = description
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		startTimer()
	}
	
	private func startTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			self?.countdown -= 1
			self?.checkTimer()
		}
	}
	
	private func checkTimer() {
		guard countdown > 0 else {
			invalidateTimer()
			dismiss(animated: true, completion: nil)
			return
		}
	}
	
	func invalidateTimer() {
		timer?.invalidate()
	}
	
	deinit {
		invalidateTimer()
	}
	
	private func setupView() {
		view.addSubview(backgroundView)
		[contentImageView, toastStackView].forEach { backgroundView.addSubview($0) }
		[titleLabel, message].forEach { toastStackView.addArrangedSubview($0) }
		
		backgroundView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.height.equalTo(toastViewHeight)
		}
		
		contentImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(14)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(backgroundView.snp.height).offset(-28)
		}
		
		toastStackView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(14)
			make.left.equalTo(contentImageView.snp.right).offset(10)
			make.right.equalToSuperview().offset(-14)
			make.bottom.equalToSuperview().offset(-14)
		}
	}
}

extension Toast {
	var panScrollable: UIScrollView? {
		return nil
	}
	
	var shortFormHeight: PanModalHeight {
		return .contentHeight(toastViewHeight)
	}
	
	var longFormHeight: PanModalHeight {
		return shortFormHeight
	}
	
	var isUserInteractionEnabled: Bool {
		return false
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
