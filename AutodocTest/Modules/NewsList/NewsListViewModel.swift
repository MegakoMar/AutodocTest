//
//  NewsListViewModel.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation
import Combine

@MainActor
final class NewsListViewModel {
    // MARK: - Publishers
    @Published private(set) var state: NewsListState = .idle
    
    // MARK: - Private
    private let networkService: NewsNetworkService
    private let router: NewsListRouter
    private var totalCount = 0
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 1
    private var hasMorePages: Bool = true
    
    // MARK: - Initialization
    init(networkService: NewsNetworkService, router: NewsListRouter) {
        self.networkService = networkService
        self.router = router
    }
    
    func loadFirstPage(isRefreshing: Bool = false) async {
        guard !state.isLoading else {
            return
        }
        
        totalCount = 0
        state = .loading
        
        do {
            let result = try await networkService.fetchNews(page: 1)
            totalCount = result.totalCount
            
            if result.news.isEmpty {
                state = .empty
            } else {
                state = .loaded(
                    items: result.news,
                    isRefreshing: isRefreshing
                )
            }
            currentPage += 1
            hasMorePages = !result.news.isEmpty
            
        } catch {
            state = .error(errorMessage: error.localizedDescription)
        }
    }
    
    func loadNextPage() async {
        guard !state.isLoading, case let .loaded(items, _) = state, hasMorePages else {
            return
        }
        
        state = .loadingMore(items: items)
        
        do {
            let result = try await networkService.fetchNews(page: currentPage)
            let newItems = items + result.news
            state = .loaded(items: newItems)
            currentPage += 1
            hasMorePages = newItems.count < result.totalCount
        } catch {
            // Показать ошибку
            state = .loaded(items: items)
        }
    }
    
    func refresh() async {
        await loadFirstPage(isRefreshing: true)
    }
    
    func showDetails(for fullUrl: String) {
        router.showDetails(for: fullUrl)
    }
}
