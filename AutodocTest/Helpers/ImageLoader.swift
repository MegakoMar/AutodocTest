//
//  ImageLoader.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import UIKit

final class ImageLoader {
    // MARK: - Private
    
    private let cache = URLCache.shared
    private var cacheLock = NSLock()
    
    private init() {}
    
    static let shared = ImageLoader()
    
    func loadImage(from sourcre: String?) async throws -> UIImage? {
        guard let sourcre, let url = URL(string: sourcre) else {
            return nil
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, for: request)
        return UIImage(data: data)
    }
    
    func cachedImage(from sourcre: String?) -> UIImage? {
        guard let sourcre, let url = URL(string: sourcre) else {
            return nil
        }
        
        let request = URLRequest(url: url)
        
        guard let image = requestFromCache(request) else {
            return nil
        }
        
        return image
    }
    
    private func requestFromCache(_ request: URLRequest) -> UIImage? {
        cacheLock.lock()
        
        defer {
            cacheLock.unlock()
        }
        
        guard let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
}

