//
//  NewsListViewModel.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation
import Combine

@MainActor
protocol NewsListViewModel: AnyObject {
    var state: NewsListState { get }
    var statePublisher: AnyPublisher<NewsListState, Never> { get }
    var errorSnackPublisher: AnyPublisher<String, Never> { get }
    
    func loadFirstPage(isRefreshing: Bool)
    func loadNextPage()
    func refresh()
    func showDetails(for fullUrl: String)
}

extension NewsListViewModel {
    func loadFirstPage() {
        loadFirstPage(isRefreshing: false)
    }
}
