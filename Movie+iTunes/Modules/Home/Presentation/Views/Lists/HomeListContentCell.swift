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
		doubleTapPublisher = PassthroughSubject<Void, Never>()
	}
	
	internal let cancellabels = CancelBag()
	internal var doubleTapPublisher = PassthroughSubject<Void, Never>()
	
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
	
	private let overlayView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.alpha = 0
		return view
	}()
	
	private let addedLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.textColor = .black
		return label
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
		
		contentView.addSubview(overlayView)
		overlayView.addSubview(addedLabel)
		
		overlayView.snp.makeConstraints { make in
			make.edges.equalTo(imageContainerView)
		}
		
		addedLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().offset(10)
			make.right.equalToSuperview().offset(-10)
		}
		
		handleGesture()
	}
	
	private func handleGesture() {
		// Double Tap
		let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		doubleTap.numberOfTapsRequired = 2
		self.contentView.addGestureRecognizer(doubleTap)
		
		doubleTap.delaysTouchesBegan = true
	}
	
	// Animation when double tap
	@objc func handleDoubleTap() {
		contentView.isUserInteractionEnabled = false
		UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeCubic, animations: { [weak self] in
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
				self?.overlayView.alpha = 0.7
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.1) {
				self?.overlayView.alpha = 0
			}
			
		}) { [weak self] isComplete in
			self?.doubleTapPublisher.send(())
			self?.layoutIfNeeded()
			self?.contentView.isUserInteractionEnabled = true
		}
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
	
	internal func set(isLiked: Bool) {
		addedLabel.text = isLiked ? "Removed from favorite" : "Added to favorite"
	}
}
