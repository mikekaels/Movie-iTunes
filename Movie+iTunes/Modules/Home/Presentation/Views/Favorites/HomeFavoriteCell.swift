//
//  HomeFavoriteCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import SnapKit

internal final class HomeFavoriteCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}
	
	private let sectionTitleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .theme(.background)
		return label
	}()
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 100, height: 150)
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
			cell.set(url: movie.posterPath, image: movie.image)
			return cell
		}
		return dataSource
	}()
	
	private func setupView() {
		contentView.backgroundColor = .clear
		[sectionTitleLabel, collectionView].forEach { contentView.addSubview($0) }
		
		sectionTitleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.width.equalToSuperview().offset(-32)
			make.centerX.equalToSuperview()
		}
		
		collectionView.snp.makeConstraints { make in
			make.top.equalTo(sectionTitleLabel.snp.bottom).offset(10)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(150)
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
