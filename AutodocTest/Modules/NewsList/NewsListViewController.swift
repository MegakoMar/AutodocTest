//
//  NewsListViewController.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Combine
import UIKit

final class NewsListViewController: UIViewController {
    // MARK: Private
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(NewsListCell.self, forCellWithReuseIdentifier: NewsListCell.reuseIdentifier)
//        collectionView.register(
//            LoadingFooterView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
//            withReuseIdentifier: LoadingFooterView.reuseIdentifier
//        )
        return collectionView
    }()
    
    private lazy var refreshControl = UIRefreshControl()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var viewModel: NewsListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>
    
    private lazy var dataSource = createDataSoucre()
    
    private enum Section: Hashable, Sendable {
        case main
    }
    
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
        setupRefreshControl()
        applySnapshot(animate: false)
        
        Task { [weak self] in
            await self?.viewModel.loadFirstPage()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
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
        case let .loaded(items, _, isRefreshing):
            applySnapshot(items: items, isRefreshing: isRefreshing)
        case let .error(errorMessage, items):
            if !items.isEmpty {
                applySnapshot(items: items)
                // Показать снек
            } else {
                // Показать состояние полноэкранной ошибки
            }
//        case .empty:
//            // Показать пустое состояние
        default:
            return
        }
    }
    
    // MARK: - Layout
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _,_ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            
            return section
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
                    id: item.id,
                    title: item.title,
                    imageUrl: item.titleImageUrl
                )
            )
            
            let itemsCount = self.dataSource.snapshot().numberOfItems

            if indexPath.item == itemsCount - 3 && itemsCount > 0 {
                Task { [weak self] in
                   await self?.viewModel.loadNextPage()
                }
            }
            
            return cell
        }
        
//        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
//            guard let self, kind == UICollectionView.elementKindSectionFooter else {
//                return nil
//            }
//            
//            guard let footer = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: LoadingFooterView.reuseIdentifier,
//                for: indexPath
//            ) as? LoadingFooterView else {
//                return UICollectionReusableView()
//            }
//            
//            if case .loadingMore = self.viewModel.state {
//                footer.startAnimating()
//            } else {
//                footer.stopAnimating()
//            }
//            
//            return footer
//        }
        
        return dataSource
    }
    
    private func applySnapshot(items: [NewsItem] = [], isRefreshing: Bool = false, animate: Bool = true) {
        print("ITEMS \(items.count)")
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
    
    @objc private func refreshPulled() {
        Task { [weak self] in
            await self?.viewModel.refresh()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        print(item.fullUrl)
    }
}
