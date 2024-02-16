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

internal final class TrailerCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private let cancellables = CancelBag()
	
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
		button.setImage(UIImage(systemName: "pause.circle.fill"), for: .selected)
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
		
		contentView.addSubview(playButton)
		playButton.snp.makeConstraints { make in
			make.size.equalTo(100)
			make.center.equalTo(videoView)
		}
		
		playButton.tapPublisher
			.sink { [weak self] _ in
				self?.playButton.isSelected.toggle()
			}
			.store(in: cancellables)
	}
}

extension TrailerCell {
	func set(trailerURL: String) {
		self.url = trailerURL
	}
}
