//
//  AuthorizationSignUpViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthorizationSignUpViewController: RegistrationViewController {
    override var reportAnalytics: Bool {
        return false
    }

    // MARK: - Builder

    static func make() -> RegistrationViewController {
        let vc = ControllerHelper.instantiateViewController(identifier: "Registration", storyboardName: "Auth")
        object_setClass(vc, AuthorizationSignUpViewController.self)

        return vc as! AuthorizationSignUpViewController
    }
}
