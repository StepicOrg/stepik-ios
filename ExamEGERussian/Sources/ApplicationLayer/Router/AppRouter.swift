//
//  AppRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AppRouter: BaseRouter {
    private(set) weak var window: UIWindow?

    func start(_ window: UIWindow) {
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func showTopics(animated: Bool = true) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.topicsAssembly.module(navigationController: navigationController)
        }, animated: animated)
    }
}

extension AppRouter: AuthorizationPresentable {
    func showAuthorization(animated: Bool) {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authAssembly.greeting.module()
        }, animated: animated)
    }
}
