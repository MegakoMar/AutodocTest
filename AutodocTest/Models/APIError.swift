//
//  APIError.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case unexpectedStatusCode(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.Error.invalidUrl
        case .noData:
            return L10n.Error.noData
        case let .decodingError(error):
            return L10n.Error.decodingError(error.localizedDescription)
        case let .networkError(error):
            return L10n.Error.networkError(error.localizedDescription)
        case let .unexpectedStatusCode(code):
            return L10n.Error.unexpectedStatusCode(code)
        case .unknown:
            return L10n.Error.unknown
        }
    }
}
