//
//  APIClient.swift
//  AutodocTest
//
//  Created by Roman Komarov on 07.10.2026.
//

import Foundation

protocol APIClient: Sendable {
    func request<T: Decodable & Sendable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T
}
