//
//  AppRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AppRouter: BaseRouter {

    weak var window: UIWindow?
    weak var rootViewController: UIViewController? {
        return window?.rootViewController ?? navigationController
    }

    // MARK: Public API

    func showAuthorization(animated: Bool = true) {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authorizationAssembly().greeting().module()
        }, animated: animated)
    }

    func showMain(animated: Bool = true) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.mainAssembly().module(navigationController: navigationController)
        }, animated: animated)
    }

}
