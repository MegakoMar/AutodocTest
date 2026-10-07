//
//  NewsListState.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

enum NewsListState: Equatable, Sendable {
    case idle
    case loading
    case loaded(items: [NewsItem], isRefreshing: Bool = false)
    case loadingMore
    case error(errorMessage: String)
    case empty
    
    var isLoading: Bool {
        switch self {
        case .loading, .loadingMore:
            return true
        default:
            return false
        }
    }
}
