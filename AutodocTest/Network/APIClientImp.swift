//
//  APIClientImp.swift
//  AutodocTest
//
//  Created by Roman Komarov on 07.10.2026.
//

import Foundation

final class APIClientImp: APIClient {
    // MARK: - Private
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
    
    // MARK: - APIClient
    
    func request<T: Decodable & Sendable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let (data, response) = try await performRequest(endpoint: endpoint)
        try validateResponse(response: response, data: data)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    private func performRequest(endpoint: APIEndpoint) async throws -> (Data, URLResponse) {
        let request: URLRequest
        do {
            request = try endpoint.request()
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.unknown
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            return (data, response)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                throw APIError.networkError(error)
            default:
                throw APIError.networkError(error)
            }
        } catch {
            throw APIError.unknown
        }
    }
    
    private func validateResponse(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
}
