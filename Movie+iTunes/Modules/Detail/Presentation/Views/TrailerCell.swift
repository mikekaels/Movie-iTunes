//
//  TrailerCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 15/02/24.
//

import UIKit
import SnapKit
import AVKit
import AVFoundation
import Combine
import CombineCocoa

internal final class TrailerCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var playerLayer = AVPlayerLayer()
	private let cancellables = CancelBag()
	private var player = AVPlayer()
	
	private let sectionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .black
		label.text = "Trailers"
		return label
	}()
	
	private let videoView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 10
		view.backgroundColor = .black
		view.layer.masksToBounds = true
		return view
	}()
	
	private let playButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		button.tintColor = .systemGray
		button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
		button.imageView?.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		button.alpha = 0.5
		return button
	}()
	
	var url: String = ""
	
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
		
		playerLayer.frame = videoView.bounds
		videoView.layer.addSublayer(playerLayer)
		
		contentView.addSubview(playButton)
		playButton.snp.makeConstraints { make in
			make.size.equalTo(100)
			make.center.equalTo(videoView)
		}
		
		playButton.tapPublisher
			.sink { [weak self] _ in
				self?.play()
			}
			.store(in: cancellables)
	}
	
	func play() {
		if let url = URL(string: self.url), player.currentTime().value == 0{
			player.replaceCurrentItem(with: AVPlayerItem(url: url))
			playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = videoView.bounds.inset(by: UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
			videoView.layer.addSublayer(playerLayer)
			player.play()
			playButton.setImage(nil, for: .normal)
			
		} else if player.timeControlStatus.rawValue == 0 {
			player.play()
			playButton.setImage(nil, for: .normal)
			
		} else {
			player.pause()
			playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
		}
		print(player.rate)
	}
}

extension TrailerCell {
	func set(trailerURL: String) {
		self.url = trailerURL
	}
}
