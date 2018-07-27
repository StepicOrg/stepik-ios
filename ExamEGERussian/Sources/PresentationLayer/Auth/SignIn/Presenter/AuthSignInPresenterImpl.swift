//
//  AuthSignInPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class AuthSignInPresenterImpl: AuthSignInPresenter {
    private weak var view: AuthSignInView?
    private let router: AuthSignInRouter
    private let userRegistrationService: UserRegistrationService

    init(view: AuthSignInView, router: AuthSignInRouter, userRegistrationService: UserRegistrationService) {
        self.view = view
        self.router = router
        self.userRegistrationService = userRegistrationService
    }

    func signIn(with email: String, password: String) {
        view?.state = .loading

        userRegistrationService.signIn(email: email, password: password).done { [weak self] _ in
            self?.view?.update(with: .success)
            self?.router.dismiss()
        }.catch { [weak self] error in
            switch error {
            case is NetworkError:
                print("email auth: successfully signed in, but could not get user")
                self?.view?.update(with: .success)
            case SignInError.manyAttempts:
                self?.view?.update(with: AuthSignInResult.manyAttempts)
            case SignInError.invalidEmailAndPassword:
                self?.view?.state = AuthSignInState.validationError
            case SignInError.badConnection:
                self?.view?.update(with: AuthSignInResult.badConnection)
            default:
                self?.view?.update(with: AuthSignInResult.error)
            }
        }
    }

    func resetPassword() {
        router.showResetPassword()
    }

    func signUp() {
        router.showSignUp()
    }

    func cancel() {
        router.pop()
    }
}
