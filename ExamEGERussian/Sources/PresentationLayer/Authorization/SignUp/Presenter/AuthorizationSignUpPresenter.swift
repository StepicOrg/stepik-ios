//
//  AuthorizationSignUpPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class AuthorizationSignUpPresenter: RegistrationPresenter {
    override func register(with name: String, email: String, password: String) {
        AuthInfo.shared.clearToken {
            super.register(with: name, email: email, password: password)
        }
    }
    override func handleTokenReceived(token: StepicToken, authorizationType: AuthorizationType) {
        AuthInfo.shared.token = token
        AuthInfo.shared.authorizationType = authorizationType
        AuthInfo.shared.isFake = .no
    }

    override func handleNotificationsStatusReceived(_ notificationsStatus: NotificationsStatus) {
    }
}
