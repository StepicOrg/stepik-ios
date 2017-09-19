//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

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
        case .error:
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        }
    }
}

class RegistrationViewController: UIViewController {
    var presenter: RegistrationPresenter?

    @IBOutlet weak var alertBottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var registerButton: AuthButton!

    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var nameTextField: AuthTextField!
    @IBOutlet weak var inputGroupPad: UIView!

    @IBOutlet weak var separatorFirstHeight: NSLayoutConstraint!
    @IBOutlet weak var separatorSecondHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var tosTextView: UITextView!

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
                let attributedString = NSMutableAttributedString(string: "\(head) \(message)")
                attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), range: NSRange(location: 0, length: head.characters.count))
                errorMessage = attributedString
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
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.onSignUpScreen, parameters: ["LoginInteractionType": "button"])

        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.register(with: name, email: email, password: password)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        presenter = RegistrationPresenter(authManager: AuthManager.sharedManager, stepicsAPI: ApiDataDownloader.stepics, view: self)

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self

        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        setup()
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
    }

    private func localize() {
        // Title
        var head = NSLocalizedString("SignUpTitleHead", comment: "")
        var attributedString = NSMutableAttributedString(string: head)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: UIFontWeightMedium), range: NSRange(location: 0, length: head.characters.count))
        titleLabel.attributedText = attributedString

        // Term of service warning
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        head = NSLocalizedString("AgreementLabelHead", comment: "")
        let and = NSLocalizedString("And", comment: "")
        let termsOfService = NSLocalizedString("AgreementLabelTermsOfService", comment: "")
        let privacyPolicy = NSLocalizedString("AgreementLabelPrivacyPolicy", comment: "")
        let string = "\(head) \(termsOfService) \(and) \(privacyPolicy)"
        attributedString = NSMutableAttributedString(string: string, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: tosTextView.font?.pointSize ?? 16, weight: UIFontWeightRegular), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.mainText, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSLinkAttributeName, value: "http://welcome.stepik.org/ru/terms", range: NSRange(location: head.characters.count + 1, length: termsOfService.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.stepicGreen, range: NSRange(location: head.characters.count + 1, length: termsOfService.characters.count))
        attributedString.addAttribute(NSLinkAttributeName, value: "http://welcome.stepik.org/ru/privacy", range: NSRange(location: head.characters.count + termsOfService.characters.count + and.characters.count + 3, length: privacyPolicy.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.stepicGreen, range: NSRange(location: head.characters.count + termsOfService.characters.count + and.characters.count + 3, length: privacyPolicy.characters.count))
        tosTextView.attributedText = attributedString

        registerButton.setTitle(NSLocalizedString("RegisterButton", comment: ""), for: .normal)
        nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        tosTextView.textContainerInset = UIEdgeInsets.zero
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.Fields.tap, parameters: nil)
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
