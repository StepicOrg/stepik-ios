//
//  EmailAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import Atributika

protocol EmailAuthViewControllerDelegate: class {
    func emailAuthViewControllerOnSuccess(_ emailAuthViewController: EmailAuthViewController)
    func emailAuthViewControllerOnClose(_ emailAuthViewController: EmailAuthViewController)
    func emailAuthViewControllerOnSignInWithSocial(_ emailAuthViewController: EmailAuthViewController)
    func emailAuthViewControllerOnSignUp(_ emailAuthViewController: EmailAuthViewController)
}

extension EmailAuthViewController: EmailAuthView {
    func update(with result: EmailAuthResult) {
        state = .normal

        switch result {
        case .success:
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
            delegate?.emailAuthViewControllerOnSuccess(self)
        case .badConnection:
            SVProgressHUD.showError(withStatus: NSLocalizedString("BadConnectionAuth", comment: ""))
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        case .manyAttempts:
            SVProgressHUD.showError(withStatus: NSLocalizedString("TooManyAttemptsSignIn", comment: ""))
        }
    }
}

class EmailAuthViewController: UIViewController {
    var presenter: EmailAuthPresenter?
    // swiftlint:disable weak_delegate
    var delegate: EmailAuthViewControllerDelegate?
    // swiftlint:enable weak_delegate

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

    private(set) var reportAnalytics: Bool = true

    @IBAction func onLogInClick(_ sender: Any) {
        view.endEditing(true)

        reportAnalyticsEvent(AnalyticsEvents.SignIn.onSignInScreen, parameters: ["LoginInteractionType": "button"])

        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.logIn(with: email, password: password)
    }

    @IBAction func onCloseClick(_ sender: Any) {
        delegate?.emailAuthViewControllerOnClose(self)
    }

    @IBAction func onSignInWithSocialClick(_ sender: Any) {
        reportAnalyticsEvent(AnalyticsEvents.SignIn.onEmailAuth, parameters: nil)
        delegate?.emailAuthViewControllerOnSignInWithSocial(self)
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        reportAnalyticsEvent(AnalyticsEvents.SignUp.onEmailAuth, parameters: nil)
        delegate?.emailAuthViewControllerOnSignUp(self)
    }

    @IBAction func onRemindPasswordClick(_ sender: Any) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString("\(StepicApplicationsInfo.stepicURL)/accounts/password/reset/", inController: self, withKey: "reset password", allowsSafari: true, backButtonStyle: BackButtonStyle.done)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(presenter != nil && delegate != nil)

        edgesForExtendedLayout = UIRectEdge.top

        localize()

        emailTextField.delegate = self
        passwordTextField.delegate = self

        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        reportAnalyticsEvent(AnalyticsEvents.SignIn.Fields.typing, parameters: nil)

        state = .normal

        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        logInButton.isEnabled = !isEmptyEmail && !isEmptyPassword
    }

    private func setup() {
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
        guard let email = self.prefilledEmail, email != "" else { return }

        emailTextField.text = email
        state = .existingEmail
    }

    private func localize() {
        titleLabel.setTextWithHTMLString(NSLocalizedString("SignInTitleEmail", comment: ""))

        signInButton.setTitle(NSLocalizedString("SignInSocialButton", comment: ""), for: .normal)
        signUpButton.setTitle(NSLocalizedString("SignUpButton", comment: ""), for: .normal)
        remindPasswordButton.setTitle(NSLocalizedString("RemindThePassword", comment: ""), for: .normal)
        logInButton.setTitle(NSLocalizedString("LogInButton", comment: ""), for: .normal)
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
    }

    private func reportAnalyticsEvent(_ event: String, parameters: [String: Any]?) {
        guard reportAnalytics else { return }
        AnalyticsReporter.reportEvent(event, parameters: parameters)
    }
}

extension EmailAuthViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        reportAnalyticsEvent(AnalyticsEvents.SignIn.Fields.tap, parameters: nil)
        // 24 - default value in app (see AppDelegate), 60 - offset with button
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = textField == passwordTextField ? 60 : 24
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }

        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()

            reportAnalyticsEvent(AnalyticsEvents.SignIn.nextButton, parameters: nil)
            reportAnalyticsEvent(AnalyticsEvents.SignIn.onSignInScreen, parameters: ["LoginInteractionType": "ime"])

            if logInButton.isEnabled {
                self.onLogInClick(logInButton)
            }
            return true
        }

        return true
    }
}
