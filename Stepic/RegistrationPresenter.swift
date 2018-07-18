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
    private let reportAnalytics: Bool

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, notificationStatusesAPI: NotificationStatusesAPI, view: RegistrationView, reportAnalytics: Bool = true) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI
        self.reportAnalytics = reportAnalytics

        self.view = view
    }

    func register(with name: String, email: String, password: String) {
        view?.state = .loading

        checkToken().then { () -> Promise<()> in
            self.authAPI.signUpWithAccount(firstname: name, lastname: " ", email: email, password: password)
        }.then { _ -> Promise<(StepicToken, AuthorizationType)> in
            self.authAPI.signInWithAccount(email: email, password: password)
        }.then { token, authorizationType -> Promise<User> in
            self.handleTokenReceived(token: token, authorizationType: authorizationType)
            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            if self.reportAnalytics {
                AnalyticsReporter.reportAmplitudeEvent(AmplitudeAnalyticsEvents.SignUp.registered, parameters: ["source": "email"])
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "registered"])
            }

            self.view?.update(with: .success)

            return self.notificationStatusesAPI.retrieve()
        }.done { result in
            self.handleNotificationsStatusReceived(result)
        }.catch { error in
            switch error {
            case PerformRequestError.noAccessToRefreshToken:
                AuthInfo.shared.token = nil
                self.view?.update(with: .error)
            case PerformRequestError.badConnection, SignInError.badConnection:
                self.view?.update(with: .badConnection)
            case is NetworkError:
                print("registration: successfully signed in, but could not get user")
                if self.reportAnalytics {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "registered"])
                }
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

    func handleTokenReceived(token: StepicToken, authorizationType: AuthorizationType) {
        AuthInfo.shared.token = token
        AuthInfo.shared.authorizationType = authorizationType

        NotificationRegistrator.shared.registerForRemoteNotificationsIfAlreadyAsked()
    }

    func handleNotificationsStatusReceived(_ notificationsStatus: NotificationsStatus) {
        NotificationsBadgesManager.shared.set(number: notificationsStatus.totalCount)
    }
}
