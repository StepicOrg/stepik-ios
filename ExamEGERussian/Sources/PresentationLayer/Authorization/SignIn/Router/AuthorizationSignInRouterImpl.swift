//
//  AuthorizationSignInRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthorizationSignInRouterImpl: BaseRouter, AuthorizationSignInRouter {
    func emailAuthViewControllerOnSuccess(_ emailAuthViewController: EmailAuthViewController) {
        dismiss()
    }

    func emailAuthViewControllerOnClose(_ emailAuthViewController: EmailAuthViewController) {
        popToRootViewController()
    }

    func emailAuthViewControllerOnSignInWithSocial(_ emailAuthViewController: EmailAuthViewController) {
    }

    func emailAuthViewControllerOnSignUp(_ emailAuthViewController: EmailAuthViewController) {
        showSignUp()
    }

    func showSignUp() {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.authorizationAssembly.signUp.module(navigationController: navigationController)
        })
    }
}
