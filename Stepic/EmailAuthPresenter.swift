//
//  EmailAuthPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol EmailAuthView: class {
    var state: EmailAuthState { get set }

    func update(with result: EmailAuthResult)
}

enum EmailAuthResult {
    case success, error, manyAttempts
}

enum EmailAuthState {
    case normal, loading, validationError, existingEmail
}

class EmailAuthPresenter {
    weak var view: EmailAuthView?

    var authManager: AuthManager
    var stepicsAPI: StepicsAPI

    init(authManager: AuthManager, stepicsAPI: StepicsAPI, view: EmailAuthView) {
        self.authManager = authManager
        self.stepicsAPI = stepicsAPI

        self.view = view
    }

    func logIn(with email: String, password: String) {
        view?.state = .loading

        authManager.logInWithUsername(email, password: password, success: { token in
            AuthInfo.shared.token = token

            // FIXME: we shouldn't have UI dependencies here...
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)

            self.stepicsAPI.retrieveCurrentUser(success: { user in
                AuthInfo.shared.user = user
                User.removeAllExcept(user)

                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "password"])
                self.view?.update(with: .success)
            }, error: { _ in
                print("email auth: successfully signed in, but could not get user")

                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "password"])
                self.view?.update(with: .success)
            })
        }, failure: { e in
            switch e {
            case .manyAttempts:
                self.view?.update(with: EmailAuthResult.manyAttempts)
            case .invalidEmailAndPassword:
                self.view?.state = EmailAuthState.validationError
            default:
                self.view?.update(with: EmailAuthResult.error)
            }
        })
    }
}
