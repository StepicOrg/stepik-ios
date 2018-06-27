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

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, notificationStatusesAPI: NotificationStatusesAPI, view: EmailAuthView) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI

        self.view = view
    }

    func logIn(with email: String, password: String) {
        view?.state = .loading

        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationRegistrator.shared.registerForRemoteNotificationsIfAlreadyAsked()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            AnalyticsReporter.reportAmplitudeEvent(AmplitudeAnalyticsEvents.SignIn.loggedIn, parameters: ["source": "email"])
            AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "password"])
            self.view?.update(with: .success)

            return self.notificationStatusesAPI.retrieve()
        }.then { result -> Void in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { error in
            switch error {
            case is NetworkError:
                print("email auth: successfully signed in, but could not get user")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "password"])
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
