//
//  AuthorizationSignUpRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthorizationSignUpRouterImpl: BaseRouter, AuthorizationSignUpRouter {
    func registrationViewControllerOnSuccess(_ registrationViewController: RegistrationViewController) {
        dismiss()
    }

    func registrationViewControllerOnClose(_ registrationViewController: RegistrationViewController) {
        popToRootViewController()
    }
}
