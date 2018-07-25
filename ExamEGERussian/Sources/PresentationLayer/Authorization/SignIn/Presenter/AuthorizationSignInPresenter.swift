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
    func handleTokenReceived(token: StepicToken, authorizationType: AuthorizationType) {
        AuthInfo.shared.token = token
        AuthInfo.shared.authorizationType = authorizationType
    }
}
