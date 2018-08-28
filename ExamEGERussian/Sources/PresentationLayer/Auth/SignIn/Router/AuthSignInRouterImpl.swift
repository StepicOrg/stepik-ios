//
//  AuthorizationSignInRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthSignInRouterImpl: BaseRouter, AuthSignInRouter {
    func showSignUp() {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.authAssembly.signUp.module(navigationController: navigationController)
        })
    }

    func showResetPassword() {
        guard let navigationController = navigationController else {
            return
        }
        WebControllerManager.sharedManager.presentWebControllerWithURLString(
            "\(StepicApplicationsInfo.stepicURL)/accounts/password/reset/",
            inController: navigationController,
            withKey: "reset password",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}
