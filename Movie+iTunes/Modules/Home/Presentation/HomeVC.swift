//
//  HomeVC.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

internal final class HomeVC: UIViewController {
	enum Section: Hashable {
		case main
	}
	
	private let viewModel: HomeVM
	private let cancellables = CancelBag()
	private let didLoadPublisher = PassthroughSubject<Void, Never>()
	private let columnButtonDidTapPublisher = PassthroughSubject<Void, Never>()
	private let movieDoubleTappedPublisher = PassthroughSubject<Int, Never>()
	private let searchDidChangePublisher = PassthroughSubject<String, Never>()
	private let searchDidCancelPublisher = PassthroughSubject<Void, Never>()

	
	init(viewModel: HomeVM = HomeVM()) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		bindViewModel()
		setupNavBar()
		bindView()
		didLoadPublisher.send(())
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupRightBarButton()
	}
	
	private lazy var searchController: UISearchController = {
		let sc = UISearchController(searchResultsController: nil)
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.autocapitalizationType = .words
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.placeholder = "Search"
		return sc
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = UITableView.automaticDimension
		tableView.separatorStyle = .none
		tableView.register(HomeFavoriteCell.self, forCellReuseIdentifier: HomeFavoriteCell.identifier)
		tableView.register(HomeListCell.self, forCellReuseIdentifier: HomeListCell.identifier)
		return tableView
	}()
	
	private lazy var dataSource: UITableViewDiffableDataSource<Section, HomeVM.DataSourceType> = {
		let dataSource = UITableViewDiffableDataSource<Section, HomeVM.DataSourceType>(tableView: tableView) { [weak self] tableView, indexPath, type in
			
			if case let .favorites(title, movies) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavoriteCell.identifier, for: indexPath) as? HomeFavoriteCell {
				cell.set(title: title)
				cell.set(contents: movies)
				return cell
			}
			
			if case let .lists(title, movies, column) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCell.identifier, for: indexPath) as? HomeListCell {
				self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: column.icon)
				cell.set(column: column.intValue, height: column.height)
				cell.set(title: title)
				cell.set(contents: movies)
				
				cell.movieDoubleTapPublisher
					.sink { [weak self] hashValue in
						self?.movieDoubleTappedPublisher.send(hashValue)
					}
					.store(in: cell.cancellabels)
				return cell
			}
			
			return UITableViewCell()
		}
		dataSource.defaultRowAnimation = .none
		return dataSource
	}()
	
	private func bindViewModel() {
		let action = HomeVM.Action(didLoad: didLoadPublisher,
								   columnButtonDidTap: columnButtonDidTapPublisher,
								   movieDoubleTap: movieDoubleTappedPublisher,
								   searchDidCancel: searchDidCancelPublisher,
								   searchDidChange: searchDidChangePublisher
		)
		let state = viewModel.transform(action, cancellables)
		
		state.$dataSources
			.receive(on: DispatchQueue.main)
			.sink { [weak self] items in
				guard let self = self else { return }
				var snapshoot = NSDiffableDataSourceSnapshot<Section, HomeVM.DataSourceType>()
				snapshoot.appendSections([.main])
				snapshoot.appendItems(items, toSection: .main)
				self.dataSource.apply(snapshoot, animatingDifferences: false)
			}
			.store(in: cancellables)
	}
	
	private func bindView() {
		searchController.searchBar.cancelButtonClickedPublisher
			.sink { [weak self] _ in
				self?.searchDidCancelPublisher.send(())
			}
			.store(in: cancellables)
		
		searchController.searchBar.textDidChangePublisher
			.debounce(for: 0.75, scheduler: DispatchQueue.main)
			.sink { [weak self] text in
				self?.searchDidChangePublisher.send(text)
			}
			.store(in: cancellables)
	}
	
	private func setupView() {
		view.backgroundColor = .white
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	private func setupNavBar() {
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
		navigationItem.searchController = searchController
		navigationController?.navigationBar.prefersLargeTitles = false
	}
	
	private func setupRightBarButton() {
		let rightButton = UIBarButtonItem(image: .init(systemName: "rectangle.split.3x3"), style: .plain, target: self, action: #selector(updateColumnFlowLayout))
		navigationItem.rightBarButtonItem = rightButton
	}
	
	@objc func updateColumnFlowLayout() {
		columnButtonDidTapPublisher.send(())
	}
}
