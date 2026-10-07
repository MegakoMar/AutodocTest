//
//  NewsEndpoint.swift
//  AutodocTest
//
//  Created by Roman Komarov on 07.10.2026.
//

import Foundation

enum NewsEndpoint: APIEndpoint {
    case getNews(page: Int, pageSize: Int)
    
    var baseURLString: String {
        "https://webapi.autodoc.ru"
    }
    
    var path: String {
        switch self {
        case .getNews(let page, let pageSize):
            return "/api/news/\(page)/\(pageSize)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getNews:
            return .get
        }
    }
}
