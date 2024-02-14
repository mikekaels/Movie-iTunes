//
//  HomeFavoriteCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import SnapKit
import Combine

internal final class HomeFavoriteCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		tapPublisher = PassthroughSubject<SectionTap, Never>()
	}
	
	internal let cancellabels = CancelBag()
	internal var tapPublisher = PassthroughSubject<SectionTap, Never>()
	
	private let sectionTitleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .theme(.background)
		return label
	}()
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 80, height: 100)
		layout.scrollDirection = .horizontal
		layout.sectionInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
		
		let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collection.backgroundColor = .clear
		collection.showsHorizontalScrollIndicator = false
		
		collection.register(HomeFavoriteContentCell.self, forCellWithReuseIdentifier: HomeFavoriteContentCell.identifier)
		return collection
	}()
	
	private lazy var dataSource: UICollectionViewDiffableDataSource<String, Movie> = {
		let dataSource = UICollectionViewDiffableDataSource<String, Movie>(collectionView: collectionView) { [weak self] collectionView, indexPath, movie in
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFavoriteContentCell.identifier, for: indexPath) as! HomeFavoriteContentCell
			cell.set(url: movie.poster.tiny, image: movie.poster.imageTiny)
			
			cell.tapPublisher
				.sink { [weak self] tap in
					self?.tapPublisher.send(.favorite(tap, movie.hashValue))
				}
				.store(in: cell.cancellabels)
			return cell
		}
		return dataSource
	}()
	
	private func setupView() {
		contentView.backgroundColor = .clear
		[sectionTitleLabel, collectionView].forEach { contentView.addSubview($0) }
		
		sectionTitleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(25)
			make.width.equalToSuperview().offset(-32)
			make.centerX.equalToSuperview()
		}
		
		collectionView.snp.makeConstraints { make in
			make.top.equalTo(sectionTitleLabel.snp.bottom).offset(10)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(120)
			make.bottom.equalToSuperview().offset(-10)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HomeFavoriteCell {
	internal func set(contents: [Movie]) {
		var snapshoot = NSDiffableDataSourceSnapshot<String, Movie>()
		snapshoot.appendSections(["main"])
		snapshoot.appendItems(contents, toSection: "main")
		self.dataSource.apply(snapshoot, animatingDifferences: true)
	}
	
	internal func set(title: String) {
		self.sectionTitleLabel.text = title
	}
}
