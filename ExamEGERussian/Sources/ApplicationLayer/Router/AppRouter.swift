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
    var tabBarController: UITabBarController? {
        return window?.rootViewController as? UITabBarController
    }

    override var navigationController: UINavigationController? {
        return tabBarController?.selectedViewController as? UINavigationController
    }

    init(window: UIWindow,
         navigationController: UINavigationController,
         assemblyFactory: AssemblyFactory
    ) {
        self.window = window
        super.init(assemblyFactory: assemblyFactory, navigationController: navigationController)
    }

    func showAuthorization(animated: Bool = true) {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authAssembly.greeting.module()
        }, animated: animated)
    }
}
