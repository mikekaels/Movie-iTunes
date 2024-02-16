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
	enum Section {
		case main
	}
	
	private let viewModel: HomeVM
	private var searchText: String = ""
	
	private let cancellables = CancelBag()
	private let didLoadPublisher = PassthroughSubject<Void, Never>()
	private let columnButtonDidTapPublisher = PassthroughSubject<Void, Never>()
	private let movieTapPublisher = PassthroughSubject<SectionTap, Never>()
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
		navigationController?.navigationBar.isHidden = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	private lazy var searchController: UISearchController = {
		let sc = UISearchController(searchResultsController: nil)
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.autocapitalizationType = .words
		sc.searchBar.searchTextField.enablesReturnKeyAutomatically = false
		sc.searchBar.keyboardType = .twitter
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
		tableView.register(HomeErrorCell.self, forCellReuseIdentifier: HomeErrorCell.identifier)
		return tableView
	}()
	
	private lazy var dataSource: UITableViewDiffableDataSource<Section, HomeVM.DataSourceType> = {
		let dataSource = UITableViewDiffableDataSource<Section, HomeVM.DataSourceType>(tableView: tableView) { [weak self] tableView, indexPath, type in
			
			if case let .favorites(title, movies) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavoriteCell.identifier, for: indexPath) as? HomeFavoriteCell {
				cell.set(title: title)
				cell.set(contents: movies)
				
				cell.tapPublisher
					.sink { [weak self] value in
						self?.movieTapPublisher.send(value)
					}
					.store(in: cell.cancellabels)
				return cell
			}
			
			if case let .lists(title, movies) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCell.identifier, for: indexPath) as? HomeListCell {
				cell.set(title: title)
				cell.set(contents: movies)
				
				cell.tapPublisher
					.sink { [weak self] value in
						self?.movieTapPublisher.send(value)
					}
					.store(in: cell.cancellabels)
				return cell
			}
			
			if case let .error(type) = type, let cell = tableView.dequeueReusableCell(withIdentifier: HomeErrorCell.identifier, for: indexPath) as? HomeErrorCell {
				cell.set(image: type.image)
				cell.set(title: type.title)
				cell.set(description: type.desc)
				cell.set(buttonTitle: type.buttonTitle)
				
				cell.buttonDidTapPublisher
					.sink { [weak self] _ in
						self?.didLoadPublisher.send(())
					}
					.store(in: cell.cancellables)
				return cell
			}
			
			return UITableViewCell()
		}
		dataSource.defaultRowAnimation = .fade
		return dataSource
	}()
	
	private func bindViewModel() {
		let action = HomeVM.Action(didLoad: didLoadPublisher,
								   columnButtonDidTap: columnButtonDidTapPublisher,
								   movieTapped: movieTapPublisher,
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
				self.dataSource.apply(snapshoot, animatingDifferences: true)
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
				self?.searchText = text
				self?.searchDidChangePublisher.send(text)
			}
			.store(in: cancellables)
		
		searchController.searchBar.searchTextField.didBeginEditingPublisher
			.sink { [weak self] _ in
				self?.searchController.searchBar.searchTextField.text = self?.searchText ?? ""
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
	
	@objc func updateColumnFlowLayout() {
		columnButtonDidTapPublisher.send(())
	}
}
