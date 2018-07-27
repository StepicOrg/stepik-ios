//
//  AuthorizationSignInViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import Atributika

final class AuthSignInViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet var stepikLogoHeightConstraint: NSLayoutConstraint!
    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var alertBottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet var separatorHeight: NSLayoutConstraint!

    @IBOutlet var logInButton: AuthButton!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var emailTextField: AuthTextField!
    @IBOutlet var passwordTextField: AuthTextField!
    @IBOutlet var inputGroupPad: UIView!
    @IBOutlet var titleLabel: StepikLabel!
    @IBOutlet var remindPasswordButton: UIButton!
    @IBOutlet var signUpButton: UIButton!

    // MARK: Instance Properties

    var presenter: AuthSignInPresenter?
    var prefilledEmail: String?

    var state: AuthSignInState = .normal {
        didSet {
            switch state {
            case .normal:
                errorMessage = nil
                SVProgressHUD.dismiss()
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.0)
            case .loading:
                SVProgressHUD.show()
            case .validationError:
                let head = NSLocalizedString("WhoopsHead", comment: "")
                let error = NSLocalizedString("ValidationEmailAndPasswordError", comment: "")
                let message = "\(head) \(error)"
                let range = message.startIndex..<message.index(message.startIndex, offsetBy: head.count)
                errorMessage = message.style(range: range, style: Style.font(.systemFont(ofSize: 16, weight: UIFont.Weight.medium))).attributedString
                logInButton.isEnabled = false

                SVProgressHUD.dismiss()
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.05)
            case .existingEmail:
                let head = NSLocalizedString("WhoopsHead", comment: "")
                let error = NSLocalizedString("SocialSignupWithExistingEmailError", comment: "")
                let message = "\(head) \(error)"
                let range = message.startIndex..<message.index(message.startIndex, offsetBy: head.count)
                errorMessage = message.style(range: range, style: Style.font(.systemFont(ofSize: 16, weight: UIFont.Weight.medium))).attributedString
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.05)
            }
        }
    }

    var errorMessage: NSAttributedString? = nil {
        didSet {
            alertLabel.attributedText = errorMessage
            if errorMessage != nil {
                alertBottomLabelConstraint.constant = 16
                alertLabelHeightConstraint.isActive = false
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                alertBottomLabelConstraint.constant = -6
                alertLabelHeightConstraint.isActive = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    // MARK: - UIViewController Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prefill()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Reset to default value (see AppDelegate)
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Drop state after rotation to prevent layout issues on small screens
        switch state {
        case .validationError:
            state = .normal
        default:
            break
        }
    }

    // MARK: - Private API -

    private func setup() {
        edgesForExtendedLayout = .top

        emailTextField.delegate = self
        passwordTextField.delegate = self

        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Dismiss Auth")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(onCloseClick(_:))
        )

        // Input group
        separatorHeight.constant = 0.5
        inputGroupPad.layer.borderWidth = 0.5
        inputGroupPad.layer.borderColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1.0).cgColor
        passwordTextField.fieldType = .password

        // Small logo for small screens
        if DeviceInfo.current.diagonal <= 4 {
            stepikLogoHeightConstraint.constant = 38
        }
    }

    private func prefill() {
        guard let email = self.prefilledEmail, email != "" else {
            return
        }

        emailTextField.text = email
        state = .existingEmail
    }

    private func localize() {
        titleLabel.setTextWithHTMLString(NSLocalizedString("SignInTitleEmail", comment: ""))
        signUpButton.setTitle(NSLocalizedString("SignUpButton", comment: ""), for: .normal)
        remindPasswordButton.setTitle(NSLocalizedString("RemindThePassword", comment: ""), for: .normal)
        logInButton.setTitle(NSLocalizedString("LogInButton", comment: ""), for: .normal)
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
    }

    // MARK: Actions

    @IBAction func onLogInClick(_ sender: Any) {
        view.endEditing(true)

        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.signIn(with: email, password: password)
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        presenter?.signUp()
    }

    @IBAction func onRemindPasswordClick(_ sender: Any) {
        presenter?.resetPassword()
    }

    @objc private func onCloseClick(_ sender: Any) {
        presenter?.cancel()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        state = .normal

        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        logInButton.isEnabled = !isEmptyEmail && !isEmptyPassword
    }
}

// MARK: - AuthSignInViewController: EmailAuthView -

extension AuthSignInViewController: AuthSignInView {
    func update(with result: AuthSignInResult) {
        state = .normal
        switch result {
        case .success:
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
        case .badConnection:
            SVProgressHUD.showError(withStatus: NSLocalizedString("BadConnectionAuth", comment: ""))
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        case .manyAttempts:
            SVProgressHUD.showError(withStatus: NSLocalizedString("TooManyAttemptsSignIn", comment: ""))
        }
    }
}

// MARK: - AuthorizationSignInViewController: UITextFieldDelegate -

extension AuthSignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = textField == passwordTextField ? 60 : 24
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            if logInButton.isEnabled {
                self.onLogInClick(logInButton)
            }
        }

        return true
    }
}
