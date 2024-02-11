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
	
	private lazy var searchController: UISearchController = {
		let sc = UISearchController(searchResultsController: nil)
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.autocapitalizationType = .words
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.placeholder = "Search"
		sc.searchBar.barStyle = .black
		
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
		let dataSource = UITableViewDiffableDataSource<Section, HomeVM.DataSourceType>(tableView: tableView) { tableView, indexPath, type in
			
			if case let .favorites(title, movies) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavoriteCell.identifier, for: indexPath) as? HomeFavoriteCell {
				cell.set(title: title)
				cell.set(contents: movies)
				return cell
			}
			
			if case let .lists(title, movies) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCell.identifier, for: indexPath) as? HomeListCell {
				cell.set(title: title)
				cell.set(contents: movies)
				return cell
			}
			
			return UITableViewCell()
		}
		return dataSource
	}()
	
	private func bindViewModel() {
		let action = HomeVM.Action(didLoad: didLoadPublisher)
		let state = viewModel.transform(action, cancellables)
		
		state.$dataSources
			.receive(on: DispatchQueue.main)
			.sink { [weak self] items in
				guard let self = self else { return }
				var snapshoot = NSDiffableDataSourceSnapshot<Section, HomeVM.DataSourceType>()
				snapshoot.appendSections([.main])
				snapshoot.appendItems(items, toSection: .main)
				self.dataSource.apply(snapshoot, animatingDifferences: true)
			}
			.store(in: cancellables)
	}
	
	private func bindView() {
		
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
}
