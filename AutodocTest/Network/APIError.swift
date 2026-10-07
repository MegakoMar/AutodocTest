//
//  APIError.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case unauthorized
    case forbidden
    case notFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.Error.invalidUrl
        case .invalidResponse:
            return L10n.Error.invalidResponse
        case .noData:
            return L10n.Error.noData
        case let .decodingError(error):
            return L10n.Error.decodingError(error.localizedDescription)
        case let .encodingError(error):
            return L10n.Error.encodingError(error.localizedDescription)
        case let .networkError(error):
            return L10n.Error.networkError(error.localizedDescription)
        case let .serverError(code):
            return L10n.Error.serverError(code)
        case let .unexpectedStatusCode(code):
            return L10n.Error.unexpectedStatusCode(code)
        case .unauthorized:
            return L10n.Error.unauthorized
        case .forbidden:
            return L10n.Error.forbidden
        case .notFound:
            return L10n.Error.notFound
        case .unknown:
            return L10n.Error.unknown
        }
    }
}
