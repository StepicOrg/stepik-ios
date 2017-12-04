//
//  RegistrationPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol RegistrationView: class {
    var state: RegistrationState { get set }

    func update(with result: RegistrationResult)
}

enum RegistrationResult {
    case success, error, badConnection
}

enum RegistrationState {
    case normal, loading, validationError(message: String)
}

class RegistrationPresenter {
    weak var view: RegistrationView?

    var authAPI: AuthAPI
    var stepicsAPI: StepicsAPI
    var notificationStatusesAPI: NotificationStatusesAPI

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, notificationStatusesAPI: NotificationStatusesAPI, view: RegistrationView) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI

        self.view = view
    }

    func register(with name: String, email: String, password: String) {
        view?.state = .loading

        checkToken().then { () -> Promise<()> in
            self.authAPI.signUpWithAccount(firstname: name, lastname: " ", email: email, password: password)
        }.then { _ -> Promise<(StepicToken, AuthorizationType)> in
            self.authAPI.signInWithAccount(email: email, password: password)
        }.then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationRegistrator.sharedInstance.registerForRemoteNotifications()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "registered"])
            self.view?.update(with: .success)

            return self.notificationStatusesAPI.retrieve()
        }.then { result -> Void in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { error in
            switch error {
            case PerformRequestError.noAccessToRefreshToken:
                AuthInfo.shared.token = nil
                self.view?.update(with: .error)
            case PerformRequestError.badConnection, SignInError.badConnection:
                self.view?.update(with: .badConnection)
            case is RetrieveError:
                print("registration: successfully signed in, but could not get user")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "registered"])
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
}
