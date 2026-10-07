//
//  NewsNetworkServiceImp.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

final class NewsNetworkServiceImp: NewsNetworkService {
    // MARK: - Private
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - NewsNetworkService
    
    func fetchNews(page: Int = 1, pageSize: Int = 15) async throws -> NewsResponse {
        let endpoint = NewsEndpoint.getNews(page: page, pageSize: pageSize)
        
        return try await apiClient.request(endpoint: endpoint, responseType: NewsResponse.self)
    }
}
