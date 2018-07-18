//
//  EmailAuthPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
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

class EmailAuthPresenter {
    weak var view: EmailAuthView?

    var authAPI: AuthAPI
    var stepicsAPI: StepicsAPI
    var notificationStatusesAPI: NotificationStatusesAPI
    private let reportAnalytics: Bool

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, notificationStatusesAPI: NotificationStatusesAPI, view: EmailAuthView, reportAnalytics: Bool = true) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI
        self.reportAnalytics = reportAnalytics

        self.view = view
    }

    func logIn(with email: String, password: String) {
        view?.state = .loading

        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
            self.handleTokenReceived(token: token, authorizationType: authorizationType)
            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            if self.reportAnalytics {
                AnalyticsReporter.reportAmplitudeEvent(AmplitudeAnalyticsEvents.SignIn.loggedIn, parameters: ["source": "email"])
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "password"])
            }
            self.view?.update(with: .success)

            return self.notificationStatusesAPI.retrieve()
        }.done { result in
            self.handleNotificationsStatusReceived(result)
        }.catch { error in
            switch error {
            case is NetworkError:
                print("email auth: successfully signed in, but could not get user")
                if self.reportAnalytics {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "password"])
                }
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

    func handleTokenReceived(token: StepicToken, authorizationType: AuthorizationType) {
        AuthInfo.shared.token = token
        AuthInfo.shared.authorizationType = authorizationType

        NotificationRegistrator.shared.registerForRemoteNotificationsIfAlreadyAsked()
    }

    func handleNotificationsStatusReceived(_ notificationsStatus: NotificationsStatus) {
        NotificationsBadgesManager.shared.set(number: notificationsStatus.totalCount)
    }
}
