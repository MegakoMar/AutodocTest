//
//  NewsResponse.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import Foundation

struct NewsResponse: Decodable, Sendable {
    let news: [NewsItem]
    let totalCount: Int
}
