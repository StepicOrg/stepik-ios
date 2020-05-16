//
//  EmailAuthPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol EmailAuthView: AnyObject {
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

    private let authAPI: AuthAPI
    private let stepicsAPI: StepicsAPI
    private let notificationStatusesAPI: NotificationStatusesAPI
    private let analytics: Analytics

    init(
        authAPI: AuthAPI,
        stepicsAPI: StepicsAPI,
        notificationStatusesAPI: NotificationStatusesAPI,
        analytics: Analytics = StepikAnalytics.shared,
        view: EmailAuthView
    ) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI
        self.analytics = analytics

        self.view = view
    }

    func logIn(with email: String, password: String) {
        view?.state = .loading

        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationsRegistrationService().renewDeviceToken()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            self.analytics.send(.signInLoggedIn(source: "email"))
            self.analytics.send(.loginSucceeded(provider: .password))

            self.view?.update(with: .success)

            return self.notificationStatusesAPI.retrieve()
        }.done { result in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { error in
            switch error {
            case is NetworkError:
                print("email auth: successfully signed in, but could not get user")
                self.analytics.send(.loginSucceeded(provider: .password))
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
