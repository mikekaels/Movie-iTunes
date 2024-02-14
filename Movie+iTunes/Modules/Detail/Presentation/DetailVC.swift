//
//  DetailVC.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import SnapKit
import Kingfisher


internal final class DetailVC: UIViewController {
	enum Section {
		case main
	}
	private let viewModel: DetailVM
	private let cancellables = CancelBag()
	
	init(viewModel: DetailVM = DetailVM()) {
		self.viewModel = viewModel
//		tableHeaderView = StretchyHeaderView(poster: movie.poster)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		bindViewModel()
		bindView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		navigationController?.navigationBar.isHidden = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		UIView.animate(withDuration: 0.2) { [weak self] in
			self?.headerBackgroundView.alpha = 0
		}
	}
	
	private let backButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
		button.imageView?.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		button.tintColor = .systemGray6
		return button
	}()
	
	private let headerBackgroundView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = UITableView.automaticDimension
		tableView.separatorStyle = .none
		tableView.delegate = self
		tableView.showsVerticalScrollIndicator = false
		tableView.register(DescriptionCell.self, forCellReuseIdentifier: DescriptionCell.identifier)
		tableView.register(TrailerCell.self, forCellReuseIdentifier: TrailerCell.identifier)
		
		return tableView
	}()
	
	private lazy var dataSource: UITableViewDiffableDataSource<Section, DetailVM.DataSourceType> = {
		let dataSource = UITableViewDiffableDataSource<Section, DetailVM.DataSourceType>(tableView: tableView) { tableView, indexPath, type in
			
			if case let .header(movie) = type, let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.identifier, for: indexPath) as? DescriptionCell {
				cell.set(movie: movie)
				return cell
			}
			
			if case let .trailers(movie) = type, let cell = tableView.dequeueReusableCell(withIdentifier: TrailerCell.identifier, for: indexPath) as? TrailerCell {
				cell.set(trailerURL: movie.trailer)
				return cell
			}
			
			return UITableViewCell()
		}
		dataSource.defaultRowAnimation = .fade
		return dataSource
	}()
	
	private func bindViewModel() {
		let action = DetailVM.Action()
		let state = viewModel.transform(action, cancellables: cancellables)
		
		state.$dataSources
			.sink { [weak self] items in
				guard let self = self else { return }
				var snapshoot = NSDiffableDataSourceSnapshot<Section, DetailVM.DataSourceType>()
				snapshoot.appendSections([.main])
				snapshoot.appendItems(items, toSection: .main)
				self.dataSource.apply(snapshoot, animatingDifferences: true)
			}
			.store(in: cancellables)
		
		state.$poster
			.compactMap { $0 }
			.sink { [weak self] poster in
				if let image = poster.imageLarge {
					self?.headerBackgroundView.image = UIImage(data: image)
				} else if let url = URL(string: poster.large) {
					self?.headerBackgroundView.kf.setImage(with: url)
				}
			}
			.store(in: cancellables)
	}
	
	
	private func bindView() {
		backButton.tapPublisher
			.sink { [weak self] _ in
				self?.navigationController?.popViewController(animated: true)
			}
			.store(in: cancellables)
	}
	
	private func setupView() {
		view.backgroundColor = .white
		[headerBackgroundView, tableView, backButton].forEach { view.addSubview($0) }
		
		headerBackgroundView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.left.right.equalToSuperview()
			make.bottom.equalToSuperview().offset(180)
		}
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		backButton.snp.makeConstraints { make in
			make.size.equalTo(30)
			make.top.equalTo(view).offset(60)
			make.left.equalTo(view).offset(10)
		}
	}
	
}

extension DetailVC: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let offset: CGFloat = scrollView.contentOffset.y + 180
		print(offset)
		UIView.animate(withDuration: 0.3) { [weak self] in
			guard let self = self else { return }
			self.headerBackgroundView.snp.updateConstraints { make in
				make.bottom.equalToSuperview().offset(-offset)
			}
			self.view.layoutIfNeeded()
		}
	}
}
