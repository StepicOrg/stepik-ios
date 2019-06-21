//
//  AuthSignUpViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import TTTAttributedLabel
import Atributika

final class AuthSignUpViewController: UIViewController {
    @IBOutlet var alertBottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var stepikLogoHeightConstraint: NSLayoutConstraint!

    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var registerButton: AuthButton!

    @IBOutlet var emailTextField: AuthTextField!
    @IBOutlet var passwordTextField: AuthTextField!
    @IBOutlet var nameTextField: AuthTextField!
    @IBOutlet var inputGroupPad: UIView!

    @IBOutlet var separatorFirstHeight: NSLayoutConstraint!
    @IBOutlet var separatorSecondHeight: NSLayoutConstraint!

    @IBOutlet var titleLabel: StepikLabel!
    @IBOutlet var tosLabel: TTTAttributedLabel!

    var presenter: AuthSignUpPresenter?

    var state: AuthSignUpState = .normal {
        didSet {
            switch state {
            case .normal:
                errorMessage = nil
                SVProgressHUD.dismiss()
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.0)
            case .loading:
                SVProgressHUD.show()
            case .validationError(let message):
                let head = NSLocalizedString("WhoopsHead", comment: "")
                let fullMessage = "\(head) \(message)"
                let range = fullMessage.startIndex..<fullMessage.index(fullMessage.startIndex, offsetBy: head.count)
                errorMessage = fullMessage.style(range: range, style: Style.font(.systemFont(ofSize: 16, weight: UIFont.Weight.medium))).attributedString
                registerButton.isEnabled = false

                SVProgressHUD.dismiss()
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

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        setup()
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
        case .validationError(_):
            state = .normal
        default:
            break
        }
    }

    // MARK: - Actions

    @IBAction func onRegisterClick(_ sender: Any) {
        view.endEditing(true)

        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.signUp(name: name, email: email, password: password)
    }

    @objc private func onCloseClick(_ sender: Any) {
        presenter?.cancel()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        state = .normal

        let isEmptyName = nameTextField.text?.isEmpty ?? true
        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        registerButton.isEnabled = !isEmptyName && !isEmptyEmail && !isEmptyPassword
    }

    // MARK: - Private API

    private func setup() {
        edgesForExtendedLayout = .top

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        tosLabel.delegate = self

        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Dismiss Auth")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(onCloseClick(_:))
        )

        // Input group
        separatorFirstHeight.constant = 0.5
        separatorSecondHeight.constant = 0.5
        inputGroupPad.layer.borderWidth = 0.5
        inputGroupPad.layer.borderColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1.0).cgColor
        passwordTextField.fieldType = .password

        // Small logo for small screens
        if DeviceInfo.current.diagonal <= 4 {
            stepikLogoHeightConstraint.constant = 38
        }
    }

    private func localize() {
        titleLabel.setTextWithHTMLString(NSLocalizedString("SignUpTitle", comment: ""))

        // Term of service warning
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let head = NSLocalizedString("AgreementLabelText", comment: "")

        let all = Style.font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFont.Weight.regular))
            .foregroundColor(UIColor.mainText)
            .paragraphStyle(paragraphStyle)
        let link = Style("a").font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFont.Weight.regular)).foregroundColor(UIColor.stepicGreen)
        let activeLink = Style.font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFont.Weight.regular))
            .foregroundColor(UIColor.mainText)
            .backgroundColor(UIColor(hex: 0xF6F6F6))

        let styledText = head.style(tags: link).styleAll(all)

        tosLabel.linkAttributes = link.attributes
        tosLabel.activeLinkAttributes = activeLink.attributes
        tosLabel.setText(styledText.attributedString)

        styledText.detections.forEach { detection in
            switch detection.type {
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"] {
                    tosLabel.addLink(to: URL(string: href), with: NSRange(detection.range, in: styledText.string))
                }
            default: break
            }
        }

        registerButton.setTitle(NSLocalizedString("RegisterButton", comment: ""), for: .normal)
        nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
    }
}

// MARK: - AuthSignUpViewController: AuthSignUpView -

extension AuthSignUpViewController: AuthSignUpView {
    func update(with result: AuthSignUpResult) {
        state = .normal
        switch result {
        case .success:
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
        case .badConnection:
            SVProgressHUD.showError(withStatus: NSLocalizedString("BadConnectionAuth", comment: ""))
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        }
    }
}

// MARK: - AuthSignUpViewController: TTTAttributedLabelDelegate -

extension AuthSignUpViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString(url.absoluteString, inController: self, withKey: "tos", allowsSafari: true, backButtonStyle: BackButtonStyle.done)
    }
}

// MARK: - AuthSignUpViewController: UITextFieldDelegate -

extension AuthSignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = textField == passwordTextField ? 64 : 24
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            if registerButton.isEnabled {
                self.onRegisterClick(registerButton)
            }
        }

        return true
    }
}
