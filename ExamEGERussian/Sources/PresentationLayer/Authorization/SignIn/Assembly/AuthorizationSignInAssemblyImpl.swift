//
//  AuthorizationSignInAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthorizationSignInAssemblyImpl: BaseAssembly, AuthorizationSignInAssembly {
    func module(navigationController: UINavigationController, router _router: AuthorizationSignInRouter?) -> UIViewController {
        let vc = AuthorizationSignInViewController.make()
        vc.presenter = AuthorizationSignInPresenter(authAPI: serviceFactory.authAPI, stepicsAPI: serviceFactory.stepicsAPI, notificationStatusesAPI: serviceFactory.notificationStatusesAPI, view: vc)
        vc.delegate = _router != nil ? _router : router(navigationController: navigationController)

        return vc
    }

    func router(navigationController: UINavigationController) -> AuthorizationSignInRouter {
        return AuthorizationSignInRouterImpl(assemblyFactory: assemblyFactory, navigationController: navigationController)
    }
}
