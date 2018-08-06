//
//  AuthSignUpPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class AuthSignUpPresenterImpl: AuthSignUpPresenter {
    private weak var view: AuthSignUpView?
    private let router: AuthSignUpRouter
    private let userRegistrationService: UserRegistrationService

    init(view: AuthSignUpView, router: AuthSignUpRouter, userRegistrationService: UserRegistrationService) {
        self.view = view
        self.router = router
        self.userRegistrationService = userRegistrationService
    }

    func signUp(name: String, email: String, password: String) {
        view?.state = .loading
        let params = UserRegistrationParams(firstname: name, lastname: " ", email: email, password: password)

        userRegistrationService.registerAndSignIn(with: params).done { _ in
            self.view?.update(with: .success)
            self.router.dismiss()
        }.catch { error in
            switch error {
            case PerformRequestError.noAccessToRefreshToken:
                AuthInfo.shared.token = nil
                self.view?.update(with: .error)
            case PerformRequestError.badConnection, SignInError.badConnection:
                self.view?.update(with: .badConnection)
            case is NetworkError:
                print("registration: successfully signed in, but could not get user")
                self.view?.update(with: .success)
            case SignUpError.validation(_, _, _, _):
                if let message = (error as? SignUpError)?.firstError {
                    self.view?.state = .validationError(message: message)
                } else {
                    self.view?.update(with: .error)
                }
            default:
                self.view?.update(with: .error)
            }
        }
    }

    func cancel() {
        router.pop()
    }
}
