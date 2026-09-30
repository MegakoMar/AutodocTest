//
//  NewsNetworkService.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

protocol NewsNetworkService {
    func fetchNews(page: Int, pageSize: Int) async throws -> NewsResponse
}

extension NewsNetworkService {
    func fetchNews(page: Int) async throws -> NewsResponse {
        try await fetchNews(page: page, pageSize: 15)
    }
}
