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
    case loaded(items: [NewsItem], nextPage: Int?, isRefreshing: Bool = false)
    case loadingMore(items: [NewsItem], nextPage: Int?)
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
        case let .loaded(items, _, _), let .loadingMore(items, _), let .error(_, items):
            return items
        default:
            return []
        }
    }
    
    var hasMorePages: Bool {
        switch self {
        case let .loaded(_, nextPage, _), let .loadingMore(_, nextPage):
            return nextPage != nil
        default:
            return false
        }
    }
}
