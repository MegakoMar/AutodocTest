//
//  NewsListState.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

enum NewsListState {
    case idle
    case loading
    case loaded(items: [NewsItem], isRefreshing: Bool = false)
    case loadingMore(items: [NewsItem])
    case error(errorMessage: String, items: [NewsItem] = [])
    case empty
    
    var isLoading: Bool {
        switch self {
        case .loading, .loadingMore:
            return true
        default:
            return false
        }
    }
    
    var currentItems: [NewsItem] {
        switch self {
        case let .loaded(items, _), let .loadingMore(items), let .error(_, items):
            return items
        default:
            return []
        }
    }
}
