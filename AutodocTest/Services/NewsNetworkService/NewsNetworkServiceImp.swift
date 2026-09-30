//
//  NewsNetworkServiceImp.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

final class NewsNetworkServiceImp: NewsNetworkService {
    // MARK: - Private
    
    private let baseURLString = "https://webapi.autodoc.ru/api/news/"
    private let session: URLSession
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - NewsNetworkService
    
    func fetchNews(page: Int = 1, pageSize: Int = 15) async throws -> NewsResponse {
        let urlStr = "\(baseURLString)\(page)/\(pageSize)"
        
        guard let url = URL(string: urlStr) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.unexpectedStatusCode(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                
                return try decoder.decode(NewsResponse.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
