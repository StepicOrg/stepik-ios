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
    private(set) weak var tabBarController: UITabBarController?

    override var navigationController: UINavigationController? {
        return tabBarController?.selectedViewController as? UINavigationController
    }

    init(tabBarController: UITabBarController,
         navigationController: UINavigationController,
         assemblyFactory: AssemblyFactory
    ) {
        self.tabBarController = tabBarController
        super.init(assemblyFactory: assemblyFactory, navigationController: navigationController)
    }

    func start(_ window: UIWindow) {
        self.window = window
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    func showAuthorization(animated: Bool = true) {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authAssembly.greeting.module()
        }, animated: animated)
    }
}
