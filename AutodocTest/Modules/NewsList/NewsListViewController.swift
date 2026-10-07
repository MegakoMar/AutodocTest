//
//  NewsListViewController.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Combine
import UIKit

final class NewsListViewController: UIViewController {
    // MARK: - Private
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: NewsListCell.layout()
        )
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(NewsListCell.self, forCellWithReuseIdentifier: NewsListCell.reuseIdentifier)
        collectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.reuseIdentifier
        )
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.isHidden = true
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()
    
    private var viewModel: NewsListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>
    
    private lazy var dataSource = createDataSoucre()
    
    private enum Section: Hashable, Sendable {
        case main
    }
    
    // MARK: - Initialization
    
    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        applySnapshot(animate: false)
        
        viewModel.loadFirstPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
        
        viewModel.errorSnackPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else {
                    return
                }
                
                Snackbar.show(message: message, in: self.view)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: NewsListState) {
        if case .loading = state {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        switch state {
        case let .loaded(items, isRefreshing):
            applySnapshot(items: items, isRefreshing: isRefreshing)
        case let .error(errorMessage):
            errorView.congigure(
                with: .init(message: errorMessage, type: .error) { [weak self] in
                    self?.viewModel.loadFirstPage()
                }
            )
        case .empty:
            errorView.congigure(
                with: .init(message: L10n.NewsList.empty) { [weak self] in
                    self?.viewModel.loadFirstPage()
                }
            )
        default:
            return
        }
        
        if case .error = state {
            errorView.isHidden = false
        } else if case .empty = state {
            errorView.isHidden = false
        } else {
            errorView .isHidden = true
        }
    }
    
    // MARK: - DataSource
    
    private func createDataSoucre() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) in
            guard let self, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsListCell.reuseIdentifier, for: indexPath) as? NewsListCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(
                with: .init(
                    title: item.title,
                    imageUrl: item.titleImageUrl,
                    needDivider: item != self.dataSource.snapshot().itemIdentifiers[self.dataSource.snapshot().numberOfItems - 1]
                )
            )
            
            let itemsCount = self.dataSource.snapshot().numberOfItems

            if indexPath.item == itemsCount - 3 && itemsCount > 0 {
                self.viewModel.loadNextPage()
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard
                let self,
                kind == UICollectionView.elementKindSectionFooter,
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                    for: indexPath
                ) as? LoadingFooterView
            else {
                return UICollectionReusableView()
            }
            
            if case .loadingMore = self.viewModel.state {
                footer.startAnimating()
            } else {
                footer.stopAnimating()
            }
            
            return footer
        }
        
        return dataSource
    }
    
    private func applySnapshot(items: [NewsItem] = [], isRefreshing: Bool = false, animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animate) { [weak self] in
            guard let self, isRefreshing else {
                return
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Action
    
    @objc private func refreshPulled() {
        viewModel.refresh()
    }
}

// MARK: - UICollectionViewDelegate

extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        viewModel.showDetails(for: item.fullUrl)
    }
}
