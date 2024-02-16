//
//  HomeListContentCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import Kingfisher
import SnapKit
import Combine

internal final class HomeListContentCell: UICollectionViewCell {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		tapPublisher = PassthroughSubject<SectionTap.Tap, Never>()
	}
	
	internal let cancellabels = CancelBag()
	internal var tapPublisher = PassthroughSubject<SectionTap.Tap, Never>()
	
	private let imageContainerView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		return view
	}()
	
	private let imageView: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFill
		return image
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12, weight: .light)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .black
		return label
	}()
	
	private let descLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 10, weight: .light)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .systemGray
		return label
	}()
	
	private func setupView() {
		[imageContainerView, titleLabel, descLabel].forEach { contentView.addSubview($0) }
		
		titleLabel.snp.makeConstraints { make in
			make.left.equalTo(imageContainerView.snp.left).offset(5)
			make.right.equalTo(imageContainerView.snp.right).offset(-10)
			make.bottom.equalTo(descLabel.snp.top).offset(-5)
		}
		
		descLabel.snp.makeConstraints { make in
			make.left.equalTo(titleLabel)
			make.right.equalTo(titleLabel)
			make.bottom.equalToSuperview().offset(-20)
		}
		
		imageContainerView.addSubview(imageView)
		
		
		imageContainerView.snp.makeConstraints { make in
			make.width.equalToSuperview().offset(-24)
			make.bottom.equalTo(titleLabel.snp.top).offset(-10)
			make.centerX.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		handleGesture()
	}
	
	private func handleGesture() {
		// Double Tap
		let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
		singleTap.numberOfTapsRequired = 1
		self.contentView.addGestureRecognizer(singleTap)
		
		// Double Tap
		let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		doubleTap.numberOfTapsRequired = 2
		self.contentView.addGestureRecognizer(doubleTap)
		
		singleTap.require(toFail: doubleTap)
		singleTap.delaysTouchesBegan = true
		doubleTap.delaysTouchesBegan = true
	}
	
	@objc func handleSingleTap() {
		tapPublisher.send(.single)
	}
	
	// Animation when double tap
	@objc func handleDoubleTap() {
		tapPublisher.send(.double)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HomeListContentCell {
	internal func set(url: String, image: Data?) {
		if let imageData = image {
			self.imageView.image = UIImage(data: imageData)
		} else if let url = URL(string: url) {
			self.imageView.kf.setImage(with: url)
		}
	}
	
	internal func set(title: String) {
		titleLabel.text = title
	}
	
	internal func set(description: String) {
		descLabel.text = description
	}
}
