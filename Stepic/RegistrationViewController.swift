//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import TTTAttributedLabel
import Atributika

extension RegistrationViewController: RegistrationView {
    func update(with result: RegistrationResult) {
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
        }
    }
}

class RegistrationViewController: UIViewController {
    var presenter: RegistrationPresenter?

    @IBOutlet weak var alertBottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepikLogoHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var registerButton: AuthButton!

    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var nameTextField: AuthTextField!
    @IBOutlet weak var inputGroupPad: UIView!

    @IBOutlet weak var separatorFirstHeight: NSLayoutConstraint!
    @IBOutlet weak var separatorSecondHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var tosLabel: TTTAttributedLabel!

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

    var state: RegistrationState = .normal {
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
                errorMessage = "\(head) \(message)".style(range: 0..<head.characters.count, style: Style.font(.systemFont(ofSize: 16, weight: UIFontWeightMedium))).attributedString
                registerButton.isEnabled = false

                SVProgressHUD.dismiss()
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.05)
            }
        }
    }

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .registration, to: nil)
        }
    }

    @IBAction func onRegisterClick(_ sender: Any) {
        view.endEditing(true)

        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.onSignUpScreen, parameters: ["LoginInteractionType": "button"])

        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.register(with: name, email: email, password: password)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.top

        localize()

        presenter = RegistrationPresenter(authAPI: ApiDataDownloader.auth, stepicsAPI: ApiDataDownloader.stepics, notificationStatusesAPI: NotificationStatusesAPI(), view: self)

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        tosLabel.delegate = self

        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.Fields.typing, parameters: nil)

        state = .normal

        let isEmptyName = nameTextField.text?.isEmpty ?? true
        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        registerButton.isEnabled = !isEmptyName && !isEmptyEmail && !isEmptyPassword
    }

    private func setup() {
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

        let all = Style.font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFontWeightRegular))
            .foregroundColor(UIColor.mainText)
            .paragraphStyle(paragraphStyle)
        let link = Style("a").font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFontWeightRegular)).foregroundColor(UIColor.stepicGreen)
        let activeLink = Style.font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFontWeightRegular))
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
                    tosLabel.addLink(to: URL(string: href), with: NSRange(detection.range))
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

extension RegistrationViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString(url.absoluteString, inController: self, withKey: "tos", allowsSafari: true, backButtonStyle: BackButtonStyle.done)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.Fields.tap, parameters: nil)
        // 24 - default value in app (see AppDelegate), 64 - offset with button
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = textField == passwordTextField ? 64 : 24
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
            return true
        }

        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }

        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()

            AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.nextButton, parameters: nil)
            AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.onSignUpScreen, parameters: ["LoginInteractionType": "ime"])

            if registerButton.isEnabled {
                self.onRegisterClick(registerButton)
            }
            return true
        }

        return true
    }
}
