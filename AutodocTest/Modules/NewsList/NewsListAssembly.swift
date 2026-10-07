//
//  NewsListAssembly.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import UIKit

enum NewsListAssembly {
    @MainActor
    static func makeModule(navigationController: UINavigationController?) -> UIViewController {
        let networkService: NewsNetworkService = NewsNetworkServiceImp()
        let router: NewsListRouter = NewsListRouterImp(navigationController: navigationController)
        let newsListViewModel: NewsListViewModel = NewsListViewModelImp(networkService: networkService, router: router)
        let newsListViewController = NewsListViewController(viewModel: newsListViewModel)
        
        return newsListViewController
    }
}
