//
//  AuthorizationSignInViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SnapKit

final class AuthorizationSignInViewController: EmailAuthViewController {
    override var reportAnalytics: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.isHidden = true

        signUpButton.snp.makeConstraints { make in
            make.leading.equalTo(emailTextField.snp.leading)
        }
        signUpButton.contentHorizontalAlignment = .center
    }

    override func onSignInWithSocialClick(_ sender: Any) {
    }

    static func make() -> AuthorizationSignInViewController {
        let vc = ControllerHelper.instantiateViewController(identifier: "EmailAuth", storyboardName: "Auth")
        object_setClass(vc, AuthorizationSignInViewController.self)

        return vc as! AuthorizationSignInViewController
    }
}
