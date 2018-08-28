//
//  AuthGreetingPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class AuthGreetingPresenter: AuthGreetingPresenterProtocol {
    private let router: AuthGreetingRouter
    private let userRegistrationService: UserRegistrationService

    init(router: AuthGreetingRouter, userRegistrationService: UserRegistrationService) {
        self.router = router
        self.userRegistrationService = userRegistrationService
    }

    func signIn() {
        router.showSignIn()
    }

    func signUp() {
        router.showSignUp()
    }

    func cancel() {
        checkAuthInfo()
        router.dismiss()
    }

    private func checkAuthInfo() {
        if !AuthInfo.shared.isAuthorized {
            let params = RandomCredentialsGenerator().userRegistrationParams
            userRegistrationService.registerAndSignIn(with: params).then { user in
                self.userRegistrationService.unregisterFromEmail(user: user)
            }.cauterize()
        }
    }
}
