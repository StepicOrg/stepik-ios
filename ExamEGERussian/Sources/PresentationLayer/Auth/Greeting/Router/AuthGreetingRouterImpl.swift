//
//  AuthorizationGreetingRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthGreetingRouterImpl: BaseRouter, AuthGreetingRouter {
    func showSignIn() {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.authAssembly.signIn.module(navigationController: navigationController)
        })
    }

    func showSignUp() {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.authAssembly.signUp.module(navigationController: navigationController)
        })
    }
}
