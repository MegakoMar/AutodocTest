//
//  APIEndpoint.swift
//  AutodocTest
//
//  Created by Roman Komarov on 07.10.2026.
//

import Foundation

protocol APIEndpoint {
    var baseURLString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
}

extension APIEndpoint {
    var baseURLString: String {
        fatalError("baseURLString must be overridden")
    }
    
    var method: HTTPMethod { .get }
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Encodable? { nil }
    
    func request() throws -> URLRequest {
        guard let baseURL = URL(string: baseURLString),
            var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }
        
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(AnyEncodable(body))
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        return request
    }
}

struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    
    init(_ value: Encodable) {
        self.encodeClosure = value.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
