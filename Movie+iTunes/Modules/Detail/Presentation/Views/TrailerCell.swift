//
//  TrailerCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 15/02/24.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa
import AVFoundation

internal final class TrailerCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	internal let cancellables = CancelBag()
	internal var playPublisher = PassthroughSubject<Void, Never>()
	
	override func prepareForReuse() {
		super.prepareForReuse()
		playPublisher = PassthroughSubject<Void, Never>()
	}
	
	private let sectionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .black
		label.text = "Trailers"
		return label
	}()
	
	private let videoView: UIImageView = {
		let view = UIImageView()
		view.layer.cornerRadius = 10
		view.backgroundColor = .black
		view.layer.masksToBounds = true
		return view
	}()
	
	private let playButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		button.tintColor = .white
		button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
		button.imageView?.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		button.alpha = 0.8
		return button
	}()
	
	private func setupView() {
		contentView.backgroundColor = .white
		
		contentView.addSubview(sectionLabel)
		sectionLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(15)
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
		}
		
		contentView.addSubview(videoView)
		videoView.snp.makeConstraints { make in
			make.top.equalTo(sectionLabel.snp.bottom).offset(10)
			make.height.equalTo(200)
			make.width.equalToSuperview().offset(-40)
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-20)
		}
		
		contentView.addSubview(playButton)
		playButton.snp.makeConstraints { make in
			make.size.equalTo(100)
			make.center.equalTo(videoView)
		}
		
		playButton.tapPublisher
			.sink { [weak self] _ in
				self?.playPublisher.send()
			}
			.store(in: cancellables)
	}
}

extension TrailerCell {
	func set(trailerURL: String) {
		if let url = URL(string: trailerURL) {
			DispatchQueue.global(qos: .utility).async {
				let asset = AVAsset(url: url)
				let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
				avAssetImageGenerator.appliesPreferredTrackTransform = true
				let thumnailTime = CMTimeMake(value: 2, timescale: 1)
				do {
					let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
					let thumbNailImage = UIImage(cgImage: cgThumbImage)
					DispatchQueue.main.async { [weak self] in
						self?.videoView.image = thumbNailImage
					}
				} catch {
					print(error.localizedDescription)
				}
			}
		}
		
	}
}
