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
    private let authAPI: AuthAPI
    private let stepicsAPI: StepicsAPI

    init(view: AuthSignInView, router: AuthSignInRouter, authAPI: AuthAPI, stepicsAPI: StepicsAPI) {
        self.view = view
        self.router = router
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
    }

    func signIn(with email: String, password: String) {
        view?.state = .loading

        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            return self.stepicsAPI.retrieveCurrentUser()
        }.done { [weak self] user in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

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
        router.dismiss()
    }
}
