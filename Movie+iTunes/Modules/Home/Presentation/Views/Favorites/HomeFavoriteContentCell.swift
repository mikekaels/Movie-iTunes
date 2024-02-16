//
//  HomeFavoriteContentCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 14/02/24.
//

import UIKit
import Kingfisher
import SnapKit
import Combine

internal final class HomeFavoriteContentCell: UICollectionViewCell {
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
	
	private func setupView() {
		contentView.addSubview(imageContainerView)
		imageContainerView.snp.makeConstraints { make in
			make.width.equalToSuperview().offset(-12)
			make.bottom.equalToSuperview()
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
	}
	
	@objc func handleSingleTap() {
		tapPublisher.send(.single)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HomeFavoriteContentCell {
	internal func set(url: String, image: Data?) {
		if let imageData = image {
			self.imageView.image = UIImage(data: imageData)
		} else if let url = URL(string: url) {
			self.imageView.kf.setImage(with: url)
		}
	}
}

