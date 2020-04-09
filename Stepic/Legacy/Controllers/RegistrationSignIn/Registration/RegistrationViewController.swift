//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Atributika
import IQKeyboardManagerSwift
import SVProgressHUD
import TTTAttributedLabel
import UIKit

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

final class RegistrationViewController: UIViewController {
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

    @IBOutlet var separatorFirst: UIView!
    @IBOutlet var separatorSecond: UIView!

    private lazy var closeBarButtonItem = UIBarButtonItem.stepikCloseBarButtonItem(
        target: self,
        action: #selector(self.onCloseClick(_:))
    )

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
                let fullMessage = "\(head) \(message)"
                let range = fullMessage.startIndex..<fullMessage.index(fullMessage.startIndex, offsetBy: head.count)
                errorMessage = fullMessage.style(range: range, style: Style.font(.systemFont(ofSize: 16, weight: UIFont.Weight.medium))).attributedString
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

        self.edgesForExtendedLayout = .top

        self.presenter = RegistrationPresenter(
            authAPI: ApiDataDownloader.auth,
            stepicsAPI: ApiDataDownloader.stepics,
            notificationStatusesAPI: NotificationStatusesAPI(),
            view: self
        )

        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.tosLabel.delegate = self

        self.nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        self.setup()
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
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.Fields.typing, parameters: nil)

        state = .normal

        let isEmptyName = nameTextField.text?.isEmpty ?? true
        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        registerButton.isEnabled = !isEmptyName && !isEmptyEmail && !isEmptyPassword
    }

    private func setup() {
        // Input group
        self.separatorFirstHeight.constant = 0.5
        self.separatorSecondHeight.constant = 0.5
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

    private func localize() {
        self.titleLabel.setTextWithHTMLString(NSLocalizedString("SignUpTitle", comment: ""))

        // Term of service warning
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let head = NSLocalizedString("AgreementLabelText", comment: "")

        let all = Style
            .font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFont.Weight.regular))
            .foregroundColor(.stepikPrimaryText)
            .paragraphStyle(paragraphStyle)
        let link = Style("a")
            .font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFont.Weight.regular))
            .foregroundColor(.stepikGreen)
        let activeLink = Style
            .font(.systemFont(ofSize: tosLabel.font.pointSize, weight: UIFont.Weight.regular))
            .foregroundColor(.stepikPrimaryText)
            .backgroundColor(.stepikSecondaryBackground)

        let styledText = head.style(tags: link).styleAll(all)

        self.tosLabel.linkAttributes = link.attributes
        self.tosLabel.activeLinkAttributes = activeLink.attributes
        self.tosLabel.setText(styledText.attributedString)

        styledText.detections.forEach { detection in
            switch detection.type {
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"] {
                    tosLabel.addLink(to: URL(string: href), with: NSRange(detection.range, in: styledText.string))
                }
            default: break
            }
        }

        self.registerButton.setTitle(NSLocalizedString("RegisterButton", comment: ""), for: .normal)
        self.nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
    }

    private func colorize() {
        self.view.backgroundColor = .stepikBackground

        self.inputGroupPad.layer.borderColor = UIColor.stepikSeparator.cgColor
        self.nameTextField.textColor = .stepikPrimaryText
        self.separatorFirst.backgroundColor = .stepikSeparator
        self.emailTextField.textColor = .stepikPrimaryText
        self.separatorSecond.backgroundColor = .stepikSeparator
        self.passwordTextField.textColor = .stepikPrimaryText

        self.alertLabel.textColor = .stepikRed

        self.registerButton.backgroundColor = UIColor.stepikGreen.withAlphaComponent(0.1)
        self.registerButton.setTitleColor(.stepikGreen, for: .normal)
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
        IQKeyboardManager.shared.keyboardDistanceFromTextField = textField == passwordTextField ? 64 : 24
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
                self.onRegisterClick(registerButton!)
            }
            return true
        }

        return true
    }
}
