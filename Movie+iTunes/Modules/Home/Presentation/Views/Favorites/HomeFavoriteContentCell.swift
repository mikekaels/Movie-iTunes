//
//  HomeFavoriteContentCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
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
		view.backgroundColor = .black.withAlphaComponent(0.3)
		return view
	}()
	
	private func setupView() {
		contentView.addSubview(imageContainerView)
		
		imageContainerView.snp.makeConstraints { make in
			make.width.equalToSuperview()
			make.height.equalToSuperview()
			make.centerX.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		imageContainerView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
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


