//
//  Router.swift
//  AutodocTest
//
//  Created by Roman Komarov on 01.10.2026.
//

import UIKit

protocol Router: AnyObject {
    var navigationController: UINavigationController? { get }
    
    func push(_ viewController: UIViewController, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
}

extension Router {
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func present(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.present(viewController, animated: animated)
    }
    
    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func dismiss(animated: Bool = true) {
        navigationController?.dismiss(animated: animated)
    }
}
