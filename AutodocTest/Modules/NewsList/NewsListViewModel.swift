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
    
    func loadFirstPage(isRefreshing: Bool) async
    func loadNextPage() async
    func refresh() async
    func showDetails(for fullUrl: String)
}

extension NewsListViewModel {
    func loadFirstPage() async {
        await loadFirstPage(isRefreshing: false)
    }
}
