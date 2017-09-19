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

    @IBOutlet weak var titleLabel: UILabel!
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
                // TODO: L10n
                let attributedString = NSMutableAttributedString(string: "Whoops! \(message).")
                attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), range: NSRange(location: 0, length: 7))
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
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        presenter?.register(with: name, email: email, password: password)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = RegistrationPresenter(authManager: AuthManager.sharedManager, stepicsAPI: ApiDataDownloader.stepics, view: self)

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self

        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        setup()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        state = .normal

        let isEmptyName = nameTextField.text?.isEmpty ?? true
        let isEmptyEmail = emailTextField.text?.isEmpty ?? true
        let isEmptyPassword = passwordTextField.text?.isEmpty ?? true
        registerButton.isEnabled = !isEmptyName && !isEmptyEmail && !isEmptyPassword
    }

    private func setup() {
        // Title
        var attributedString = NSMutableAttributedString(string: "Sign Up")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: UIFontWeightMedium), range: NSRange(location: 0, length: 7))
        titleLabel.attributedText = attributedString

        // Input group
        separatorFirstHeight.constant = 0.5
        separatorSecondHeight.constant = 0.5
        inputGroupPad.layer.borderWidth = 0.5
        inputGroupPad.layer.borderColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1.0).cgColor
        passwordTextField.fieldType = .password

        // Term of service warning
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedString = NSMutableAttributedString(string: "By registering you agree to the Terms of service and Privacy policy.", attributes: [NSParagraphStyleAttributeName: paragraphStyle])
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: tosTextView.font?.pointSize ?? 16, weight: UIFontWeightRegular), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 83 / 255, green: 83 / 255, blue: 102 / 255, alpha: 1.0), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSLinkAttributeName, value: "http://welcome.stepik.org/ru/terms", range: NSRange(location: 32, length: 16))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 102.0 / 255.0, green: 204.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0), range: NSRange(location: 32, length: 16))
        attributedString.addAttribute(NSLinkAttributeName, value: "http://welcome.stepik.org/ru/privacy", range: NSRange(location: 53, length: 14))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 102.0 / 255.0, green: 204.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0), range: NSRange(location: 53, length: 14))
        tosTextView.attributedText = attributedString
    }
}

extension RegistrationViewController: UITextFieldDelegate {
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

            if registerButton.isEnabled {
                self.onRegisterClick(registerButton)
            }
            return true
        }

        return true
    }
}
