//
//  EmailAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

extension EmailAuthViewController: EmailAuthView {
    func update(with result: EmailAuthResult) {
        guard let navigationController = self.navigationController as? AuthNavigationViewController else {
            return
        }

        state = .normal

        switch result {
        case .success:
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
            navigationController.dismissAfterSuccess()
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        case .manyAttempts:
            // TODO: L10n
            SVProgressHUD.showError(withStatus: "Too many attempts. Please, try later.")
        }
    }
}

class EmailAuthViewController: UIViewController {
    var presenter: EmailAuthPresenter?

    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertBottomLabelConstraint: NSLayoutConstraint!

    @IBOutlet weak var logInButton: AuthButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var inputGroupPad: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var separatorHeight: NSLayoutConstraint!

    var state: EmailAuthState = .normal {
        didSet {
            switch state {
            case .normal:
                errorMessage = nil
                SVProgressHUD.dismiss()
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.0)
            case .loading:
                SVProgressHUD.show()
            case .validationError:
                // TODO: L10n
                let attributedString = NSMutableAttributedString(string: "Whoops! The e-mail address and/or password you specified are not correct.")
                attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), range: NSRange(location: 0, length: 7))
                errorMessage = attributedString
                logInButton.isEnabled = false

                SVProgressHUD.dismiss()
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.05)
            default: break
            }
        }
    }

    var errorMessage: NSMutableAttributedString? = nil {
        didSet {
            alertLabel.attributedText = errorMessage
            if errorMessage != nil {
                alertBottomLabelConstraint.constant = 16
                alertLabelHeightConstraint.isActive = false
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                alertBottomLabelConstraint.constant = 0
                alertLabelHeightConstraint.isActive = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    @IBAction func onLogInClick(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.logIn(with: email, password: password)
    }

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email, to: nil)
        }
    }

    @IBAction func onSignInWithSocialClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email, to: .social)
        }
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email, to: .registration)
        }
    }

    @IBAction func onRemindPasswordClick(_ sender: Any) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString("\(StepicApplicationsInfo.stepicURL)/accounts/password/reset/", inController: self, withKey: "reset password", allowsSafari: true, backButtonStyle: BackButtonStyle.done)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = EmailAuthPresenter(authManager: AuthManager.sharedManager, stepicsAPI: ApiDataDownloader.stepics, view: self)

        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        setup()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        state = .normal

        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        logInButton.isEnabled = !isEmptyEmail && !isEmptyPassword
    }

    private func setup() {
        // Title
        let attributedString = NSMutableAttributedString(string: "Sign In with e-mail")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: UIFontWeightMedium), range: NSRange(location: 0, length: 7))
        titleLabel.attributedText = attributedString

        // Input group
        separatorHeight.constant = 0.5
        inputGroupPad.layer.borderWidth = 0.5
        inputGroupPad.layer.borderColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1.0).cgColor
        passwordTextField.fieldType = .password
    }
}
