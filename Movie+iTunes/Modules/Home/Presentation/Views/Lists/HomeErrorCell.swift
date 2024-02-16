//
//  HomeErrorCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 14/02/24.
//

import UIKit
import Kingfisher
import SnapKit
import Combine

internal final class HomeErrorCell: UITableViewCell {
	
	internal let cancellables = CancelBag()
	internal var buttonDidTapPublisher = PassthroughSubject<Void, Never>()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
		bindView()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		buttonDidTapPublisher = PassthroughSubject<Void, Never>()
	}
	
	private let stackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.distribution = .fill
		stack.alignment = .center
		return stack
	}()
	
	private let contentImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private let contentTitleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.textAlignment = .left
		label.textColor = .black
		return label
	}()
	
	private let contentDescriptionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .black.withAlphaComponent(0.6)
		return label
	}()
	
	private let completionButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .clear
		button.setTitleColor(.black, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
		button.layer.cornerRadius = 6
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
		return button
	}()
	
	private func setupView() {
		contentView.snp.makeConstraints { make in
			make.height.equalTo(500)
			make.width.equalToSuperview()
		}
		
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.width.equalToSuperview()
			make.center.equalToSuperview()
		}
		
		[
			contentImageView,
			contentTitleLabel,
			contentDescriptionLabel,
			completionButton
		].forEach { stackView.addArrangedSubview($0) }
		
		contentImageView.snp.makeConstraints { make in
			make.height.equalTo(100)
		}
		
		completionButton.snp.makeConstraints { make in
			make.width.equalTo(100)
			make.height.equalTo(30)
		}
		
		stackView.setCustomSpacing(15, after: contentImageView)
		stackView.setCustomSpacing(5, after: contentTitleLabel)
		stackView.setCustomSpacing(25, after: contentDescriptionLabel)
	}
	
	private func bindView() {
		completionButton.tapPublisher
			.sink { [weak self] _ in
				self?.buttonDidTapPublisher.send(())
			}
			.store(in: cancellables)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HomeErrorCell {
	func set(title: String) {
		contentTitleLabel.text = title
	}
	
	func set(description: String) {
		contentDescriptionLabel.text = description
	}
	
	func set(image: String) {
		contentImageView.image = UIImage(named: image)
	}
	
	func set(buttonTitle: String?) {
		if let title = buttonTitle {
			completionButton.isHidden = false
			completionButton.setTitle(title, for: .normal)
		} else {
			completionButton.isHidden = true
		}
	}
}

