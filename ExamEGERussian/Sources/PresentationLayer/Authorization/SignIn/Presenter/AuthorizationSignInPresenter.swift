//
//  ExamEmailAuthPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol EmailAuthView: class {
    var state: EmailAuthState { get set }

    func update(with result: EmailAuthResult)
}

enum EmailAuthResult {
    case success, error, manyAttempts, badConnection
}

enum EmailAuthState {
    case normal, loading, validationError, existingEmail
}

final class EmailAuthPresenter {
    weak var view: EmailAuthView?

    var authAPI: AuthAPI
    var stepicsAPI: StepicsAPI

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, notificationStatusesAPI: NotificationStatusesAPI, view: EmailAuthView) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.view = view
    }

    func logIn(with email: String, password: String) {
        view?.state = .loading

        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

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
