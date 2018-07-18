//
//  AuthorizationGreetingRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthorizationGreetingRouterImpl: BaseRouter, AuthorizationGreetingRouter {
    func showSignIn() {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.authorizationAssembly().signIn().module(navigationController: navigationController)
        })
    }

    func showSignUp() {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.authorizationAssembly().signUp().module(navigationController: navigationController)
        })
    }
}
