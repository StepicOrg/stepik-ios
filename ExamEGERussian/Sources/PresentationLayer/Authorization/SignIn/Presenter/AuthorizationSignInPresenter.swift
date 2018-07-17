//
//  ExamEmailAuthPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class AuthorizationSignInPresenter: EmailAuthPresenter {
    override func logIn(with email: String, password: String) {
        view?.state = .loading

        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType
            AuthInfo.shared.isFake = .no

            return self.stepicsAPI.retrieveCurrentUser()
        }.done { user in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            self.view?.update(with: .success)
        }.catch { error in
            switch error {
            case is NetworkError:
                print("email auth: successfully signed in, but could not get user")
                self.view?.update(with: .success)
            case SignInError.manyAttempts:
                self.view?.update(with: EmailAuthResult.manyAttempts)
            case SignInError.invalidEmailAndPassword:
                self.view?.state = EmailAuthState.validationError
            case SignInError.badConnection:
                self.view?.update(with: EmailAuthResult.badConnection)
            default:
                self.view?.update(with: EmailAuthResult.error)
            }
        }
    }
}
