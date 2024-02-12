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
		tapPublisher = PassthroughSubject<Section.Tap, Never>()
	}
	
	internal let cancellabels = CancelBag()
	internal var tapPublisher = PassthroughSubject<Section.Tap, Never>()
	
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
	
	private func setupView() {
		contentView.addSubview(imageContainerView)
		
		
		imageContainerView.snp.makeConstraints { make in
			make.width.equalToSuperview().offset(-8)
			make.height.equalToSuperview().offset(-8)
			make.centerX.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		imageContainerView.addSubview(imageView)
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
}
