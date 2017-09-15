//
//  RegistrationPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol RegistrationView: class {
    var state: RegistrationState { get set }

    func update(with result: RegistrationResult)
}

enum RegistrationResult {
    case success, error
}

enum RegistrationState {
    case normal, loading, validationError(message: String)
}

class RegistrationPresenter {
    weak var view: RegistrationView?

    var authManager: AuthManager
    var stepicsAPI: StepicsAPI

    init(authManager: AuthManager, stepicsAPI: StepicsAPI, view: RegistrationView) {
        self.authManager = authManager
        self.stepicsAPI = stepicsAPI

        self.view = view
    }

    func register(with name: String, email: String, password: String) {
        view?.state = .loading

        authManager.signUpWith(name, lastname: " ", email: email, password: password, success: {
            self.authManager.logInWithUsername(email, password: password, success: { token in
                AuthInfo.shared.token = token

                // FIXME: UI dependency
                NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)

                self.stepicsAPI.retrieveCurrentUser(success: { user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)

                    // TODO: Pass "registered" to analytics
                    self.view?.update(with: .success)
                }, error: { _ in
                    print("registration: successfully signed in, but could not get user")
                    // TODO: Pass "registered" to analytics
                    self.view?.update(with: .success)
                })
            }, failure: { _ in
                self.view?.update(with: .error)
            })
        }, error: { _, registrationErrorInfo in
            if let message = registrationErrorInfo?.firstError {
                self.view?.state = .validationError(message: message)
            } else {
                self.view?.update(with: .error)
            }
        })

    }
}
