//
//  AppCoordinator.swift
//  AutodocTest
//
//  Created by Roman Komarov on 01.10.2026.
//

import UIKit

@MainActor
final class AppCoordinator {
    // MARK: - Private
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let newsListViewController = NewsListAssembly.makeModule(navigationController: navigationController)
        navigationController.viewControllers = [newsListViewController]
    }
}
