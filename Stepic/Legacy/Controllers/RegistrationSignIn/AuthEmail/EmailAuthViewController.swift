//
//  EmailAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Atributika
import IQKeyboardManagerSwift
import SVProgressHUD
import UIKit

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
        case .badConnection:
            SVProgressHUD.showError(withStatus: NSLocalizedString("BadConnectionAuth", comment: ""))
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        case .manyAttempts:
            SVProgressHUD.showError(withStatus: NSLocalizedString("TooManyAttemptsSignIn", comment: ""))
        }
    }
}

final class EmailAuthViewController: UIViewController {
    var presenter: EmailAuthPresenter?

    var prefilledEmail: String?

    @IBOutlet weak var stepikLogoHeightConstraint: NSLayoutConstraint!
    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertBottomLabelConstraint: NSLayoutConstraint!

    @IBOutlet weak var logInButton: AuthButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var inputGroupPad: UIView!
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var remindPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet var inputSeparator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!

    private lazy var closeBarButtonItem = UIBarButtonItem.stepikCloseBarButtonItem(
        target: self,
        action: #selector(self.onCloseClick(_:))
    )

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

    @IBAction func onLogInClick(_ sender: Any) {
        view.endEditing(true)

        StepikAnalytics.shared.send(.signInTapped(interactionType: .button))

        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.logIn(with: email, password: password)
    }

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email(email: nil), to: nil)
        }
    }

    @IBAction func onSignInWithSocialClick(_ sender: Any) {
        StepikAnalytics.shared.send(.tappedSignInOnEmailAuthScreen)
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email(email: nil), to: .social)
        }
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        StepikAnalytics.shared.send(.tappedSignUpOnEmailAuthScreen)
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email(email: nil), to: .registration)
        }
    }

    @IBAction func onRemindPasswordClick(_ sender: Any) {
        WebControllerManager.shared.presentWebControllerWithURLString(
            "\(StepikApplicationsInfo.stepikURL)/accounts/password/reset/",
            inController: self,
            withKey: .resetPassword,
            allowsSafari: true,
            backButtonStyle: BackButtonStyle.done
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .top

        self.presenter = EmailAuthPresenter(
            authAPI: ApiDataDownloader.auth,
            stepicsAPI: ApiDataDownloader.stepics,
            notificationStatusesAPI: NotificationStatusesAPI(),
            view: self
        )

        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self

        self.emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prefill()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Reset to default value (see AppDelegate)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 24
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        StepikAnalytics.shared.send(.loginTextFieldDidChange)

        state = .normal

        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        logInButton.isEnabled = !isEmptyEmail && !isEmptyPassword
    }

    private func setup() {
        // Input group
        self.separatorHeight.constant = 0.5
        self.inputGroupPad.layer.borderWidth = 0.5
        self.passwordTextField.fieldType = .password

        // Small logo for small screens
        if DeviceInfo.current.diagonal <= 4 {
            self.stepikLogoHeightConstraint.constant = 38
        }

        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem

        self.localize()
        self.colorize()
    }

    private func prefill() {
        guard let email = self.prefilledEmail, email != "" else {
            return
        }

        self.emailTextField.text = email
        self.state = .existingEmail
    }

    private func localize() {
        self.titleLabel.setTextWithHTMLString(NSLocalizedString("SignInTitleEmail", comment: ""))

        self.signInButton.setTitle(NSLocalizedString("SignInSocialButton", comment: ""), for: .normal)
        self.signUpButton.setTitle(NSLocalizedString("SignUpButton", comment: ""), for: .normal)
        self.remindPasswordButton.setTitle(NSLocalizedString("RemindThePassword", comment: ""), for: .normal)
        self.logInButton.setTitle(NSLocalizedString("LogInButton", comment: ""), for: .normal)
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
    }

    private func colorize() {
        self.view.backgroundColor = .stepikBackground

        self.inputGroupPad.layer.borderColor = UIColor.stepikSeparator.cgColor
        self.emailTextField.textColor = .stepikPrimaryText
        self.inputSeparator.backgroundColor = .stepikSeparator
        self.passwordTextField.textColor = .stepikPrimaryText

        self.alertLabel.textColor = .stepikRed

        self.logInButton.backgroundColor = UIColor.stepikGreen.withAlphaComponent(0.1)
        self.logInButton.setTitleColor(.stepikGreen, for: .normal)

        self.remindPasswordButton.setTitleColor(.stepikLightBlue, for: .normal)

        self.signInButton.setTitleColor(.stepikPrimaryText, for: .normal)
        self.signUpButton.setTitleColor(.stepikPrimaryText, for: .normal)
    }
}

extension EmailAuthViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        StepikAnalytics.shared.send(.loginTextFieldTapped)
        // 24 - default value in app (see AppDelegate), 60 - offset with button
        IQKeyboardManager.shared.keyboardDistanceFromTextField = textField == passwordTextField ? 60 : 24
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }

        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()

            StepikAnalytics.shared.send(.tappedSignInReturnKeyOnSignInScreen)
            StepikAnalytics.shared.send(.signInTapped(interactionType: .ime))

            if logInButton.isEnabled {
                self.onLogInClick(logInButton!)
            }
            return true
        }

        return true
    }
}
