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

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.isHidden = true

        signUpButton.snp.makeConstraints { make in
            make.leading.equalTo(emailTextField.snp.leading)
        }
        signUpButton.contentHorizontalAlignment = .center
    }

    // MARK: - Actions

    override func onLogInClick(_ sender: Any) {
        view.endEditing(true)

        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.logIn(with: email, password: password)
    }

    override func onSignInWithSocialClick(_ sender: Any) {
    }

    override func onSignUpClick(_ sender: Any) {
        delegate?.emailAuthViewControllerOnSignUp(self)
    }

    // MARK: - Builder

    static func make() -> AuthorizationSignInViewController {
        let vc = ControllerHelper.instantiateViewController(identifier: "EmailAuth", storyboardName: "Auth")
        object_setClass(vc, AuthorizationSignInViewController.self)

        return vc as! AuthorizationSignInViewController
    }

}
