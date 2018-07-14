//
//  AppRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AppRouter: BaseRouter {

    // MARK: Init

    init(window: UIWindow, assemblyFactory: AssemblyFactory) {
        let navigationController = AuthInfo.shared.isAuthorized
            ? UINavigationController()
            : assemblyFactory.authorizationAssembly().module()

        super.init(assemblyFactory: assemblyFactory, navigationController: navigationController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: Public API

    func showAuthorization(animated: Bool = true) {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authorizationAssembly().module()
        }, animated: animated)
    }

    func showMain(animated: Bool = true) {
        pushViewController(derivedFrom: { _ in
            assemblyFactory.mainAssembly().module()
        }, animated: animated)
    }

}
