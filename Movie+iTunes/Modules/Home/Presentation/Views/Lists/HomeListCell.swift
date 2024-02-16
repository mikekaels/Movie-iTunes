//
//  HomeListCell.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import SnapKit
import Combine

internal final class HomeListCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		collectionView.setContentOffset(.zero, animated: false)
		tapPublisher = PassthroughSubject<SectionTap, Never>()
	}
	
	private let sectionTitleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		label.numberOfLines = 1
		label.textAlignment = .left
		label.textColor = .theme(.background)
		return label
	}()
	
	internal let cancellabels = CancelBag()
	internal var tapPublisher = PassthroughSubject<SectionTap, Never>()
	
	private lazy var dataSource: UICollectionViewDiffableDataSource<String, HomeVM.ListDataSourceType> = {
		let dataSource = UICollectionViewDiffableDataSource<String, HomeVM.ListDataSourceType>(collectionView: collectionView) { [weak self] collectionView, indexPath, type in
			if case let .content(movie) = type, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeListContentCell.identifier, for: indexPath) as? HomeListContentCell {
				
				cell.set(url: movie.poster.tiny, image: movie.poster.imageTiny)
				cell.set(description: movie.year + " • " + movie.genre)
				cell.set(title: movie.title)
				cell.tapPublisher
					.sink { [weak self] tap in
						self?.tapPublisher.send(.list(tap, movie.hashValue))
					}
					.store(in: cell.cancellabels)
				return cell
			}
			
			if case .shimmer = type, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeContentShimmerCell.identifier, for: indexPath) as? HomeContentShimmerCell {
				return cell
			}
			return UICollectionViewCell()
		}
		return dataSource
	}()
	
	private let collectionView: UICollectionView = {
		let collection = UICollectionView(frame: .zero, collectionViewLayout: ColumnFlowLayout(height: 300, totalColumn: 2))
		collection.backgroundColor = .clear
		collection.showsVerticalScrollIndicator = false
		collection.register(HomeListContentCell.self, forCellWithReuseIdentifier: HomeListContentCell.identifier)
		collection.register(HomeContentShimmerCell.self, forCellWithReuseIdentifier: HomeContentShimmerCell.identifier)
		return collection
	}()
	
	private var collectionViewHeightConstraint: Constraint?
	
	override func layoutSubviews() {
		super.layoutSubviews()
		collectionViewHeightConstraint?.update(offset: collectionView.collectionViewLayout.collectionViewContentSize.height)
	}
	
	private func setupView() {
		contentView.addSubview(sectionTitleLabel)
		contentView.addSubview(collectionView)
		
		sectionTitleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(25)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		collectionView.snp.makeConstraints { make in
			make.top.equalTo(sectionTitleLabel.snp.bottom).offset(10)
			make.width.equalToSuperview().offset(-14)
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-32)
			collectionViewHeightConstraint = make.height.equalTo(100).constraint
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Configuration
extension HomeListCell {
	internal func set(contents: [HomeVM.ListDataSourceType]) {
		var snapshot = NSDiffableDataSourceSnapshot<String, HomeVM.ListDataSourceType>()
		snapshot.appendSections(["main"])
		snapshot.appendItems(contents, toSection: "main")
		dataSource.apply(snapshot, animatingDifferences: true)
		
		collectionView.layoutIfNeeded()
		collectionViewHeightConstraint?.update(offset: collectionView.collectionViewLayout.collectionViewContentSize.height)
	}
	
	internal func set(title: String) {
		sectionTitleLabel.text = title.capitalized
	}
}
