//
//  AuthorizationSignInAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthSignInAssemblyImpl: BaseAssembly, AuthSignInAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        let controller = AuthSignInViewController()
        let router = AuthSignInRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        controller.presenter = AuthSignInPresenterImpl(
            view: controller,
            router: router,
            authAPI: serviceFactory.authAPI,
            stepicsAPI: serviceFactory.stepicsAPI
        )

        return controller
    }
}
