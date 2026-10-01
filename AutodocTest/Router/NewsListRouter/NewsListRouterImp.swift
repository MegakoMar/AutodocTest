//
//  NewsListRouter.swift
//  AutodocTest
//
//  Created by Roman Komarov on 01.10.2026.
//

import UIKit

final class NewsListRouterImp: NewsListRouter {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func showDetails(for fullUrl: String) {
        let webViewController = WebViewController(fullUrl: fullUrl)
        push(webViewController)
    }
}
