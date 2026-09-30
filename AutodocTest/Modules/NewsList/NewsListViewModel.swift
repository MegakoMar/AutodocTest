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
    private var totalCount = 0
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(networkService: NewsNetworkService) {
        self.networkService = networkService
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
                    nextPage: result.news.count < result.totalCount ? 2 : nil,
                    isRefreshing: isRefreshing
                )
            }
            
        } catch {
            state = .error(errorMessage: error.localizedDescription)
        }
    }
    
    func loadNextPage() async {
        guard !state.isLoading,
            case let .loaded(items, nextPage, _) = state,
            let page = nextPage
        else {
            return
        }
        
        state = .loadingMore(items: items, nextPage: page)
        
        do {
            let result = try await networkService.fetchNews(page: page)
            let newItems = items + result.news
            state = .loaded(items: newItems, nextPage: page)
        } catch {
            // Показать ошибку
            state = .loaded(items: items, nextPage: nextPage)
        }
    }
    
    func refresh() async {
        await loadFirstPage(isRefreshing: true)
    }
}
