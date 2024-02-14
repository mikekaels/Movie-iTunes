//
//  DescriptionCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 14/02/24.
//

import UIKit
import SnapKit
import Combine

internal final class DescriptionCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		tapPublisher = PassthroughSubject<SectionTap, Never>()
	}
	
	private let gradientView: UIView = {
		let view = UIView()
		view.clipsToBounds = true
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
		label.numberOfLines = 1
		label.textAlignment = .center
		label.textColor = .white
		return label
	}()
	
	private let genreYearLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 13, weight: .light)
		label.numberOfLines = 1
		label.textAlignment = .center
		label.textColor = .white
		return label
	}()
	
	private let buyButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		button.layer.cornerRadius = 10
		button.backgroundColor = .white
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	private let favoriteButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		button.layer.cornerRadius = 10
		button.backgroundColor = .white
		button.tintColor = .black
		button.setImage(UIImage(systemName: "heart"), for: .normal)
		button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
		return button
	}()
	
	private let buttonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.spacing = 20
		return stackView
	}()
	
	private let descLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 13, weight: .light)
		label.numberOfLines = 7
		label.textAlignment = .justified
		label.textColor = .white
		return label
	}()
	
	internal let cancellabels = CancelBag()
	internal var tapPublisher = PassthroughSubject<SectionTap, Never>()
	
	private func setupView() {
		backgroundColor = .clear
		[gradientView, titleLabel, genreYearLabel, buttonStackView, descLabel].forEach { contentView.addSubview($0) }
		gradientView.snp.makeConstraints { make in
			make.top.equalTo(titleLabel).offset(-70)
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(400)
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			
		}
		
		genreYearLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(20)
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			
		}
		
		buttonStackView.snp.makeConstraints { make in
			make.top.equalTo(genreYearLabel.snp.bottom).offset(10)
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
		}
		
		descLabel.snp.makeConstraints { make in
			make.top.equalTo(buttonStackView.snp.bottom).offset(20)
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.bottom.equalToSuperview().offset(-23)
		}
		[buyButton, favoriteButton].forEach { buttonStackView.addArrangedSubview($0) }
		buyButton.snp.makeConstraints { make in
			make.height.equalTo(44)
		}
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func addGradient() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [
			UIColor.black.cgColor,
			UIColor.black.withAlphaComponent(0.8).cgColor,
			UIColor.clear.cgColor
		]
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
		gradientLayer.locations = [0.0, 0.8, 1.0]
		gradientView.layer.insertSublayer(gradientLayer, at: 0)
		gradientLayer.frame = contentView.bounds
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if gradientView.layer.sublayers?.first == nil {
			addGradient()
		}
	}
}

extension DescriptionCell {
	func set(movie: Movie) {
		titleLabel.text = movie.title
		
		genreYearLabel.text = movie.genre + " • " + movie.year
		
		descLabel.text = movie.description
		
		let price = Double(movie.price) ?? 0
		buyButton.setTitle("Buy $\(String(format: "%.2f", price))" , for: .normal)
	}
}
