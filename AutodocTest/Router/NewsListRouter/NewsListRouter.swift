//
//  NewsListRouter.swift
//  AutodocTest
//
//  Created by Roman Komarov on 01.10.2026.
//

import Foundation

protocol NewsListRouter: Router {
    func showDetails(for fullUrl: String)
}
