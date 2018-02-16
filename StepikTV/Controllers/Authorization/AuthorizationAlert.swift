//
//  AuthorizationAlert.swift
//  StepikTV
//
//  Created by Anton Kondrashov on 17/12/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AuthorizationAlert: NSObject {

  enum AuthType {
    case login
    case registration

    var title: String {
      switch self {
      case .login:
        return "Authorization"
      case .registration:
        return "Registration"
      }
    }

    var buttonTitle: String {
      switch self {
      case .login:
        return "Sign In"
      case .registration:
        return "Sign Up"
      }
    }
  }

  enum Answer {
    case login(email:String, passowrd:String)
    case registration(name:String, email:String, password: String)
  }

  private let authType: AuthType

  private var nameTextField: UITextField?
  private var emailTextField: UITextField?
  private var passwordTextField: UITextField?

  private var acceptAction: UIAlertAction?

  var successCompletion:((Answer) -> Void)?
  var failCompletion:(() -> Void)?

  init(type: AuthType) {
    self.authType = type
  }

  func show(in viewController: UIViewController) {
    viewController.present(createController(), animated: true, completion: nil)
  }

  private func createController() -> UIAlertController {
    let title = NSLocalizedString(authType.title, comment: "")
    let acceptButtonTitle = NSLocalizedString(authType.buttonTitle, comment: "")

    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)

    if authType == .registration {
      alertController.addTextField { [weak self] textField in
        textField.placeholder = NSLocalizedString("Name", comment: "")
        let inputAccessoryView = TitleInputAccessoryView(title: NSLocalizedString("Enter your name", comment: ""))
        textField.inputAccessoryView = inputAccessoryView

        textField.addTarget(self, action: #selector(AuthorizationAlert.handleTextChange(_:)), for: .editingChanged)
        self?.nameTextField = textField
      }
    }

    alertController.addTextField { [weak self] textField in
      textField.keyboardType = .emailAddress
      textField.placeholder = NSLocalizedString("Email", comment: "")

      let inputAccessoryView = TitleInputAccessoryView(title: NSLocalizedString("Enter your email address", comment: ""))
      textField.inputAccessoryView = inputAccessoryView

      textField.addTarget(self, action: #selector(AuthorizationAlert.handleTextChange(_:)), for: .editingChanged)
      self?.emailTextField = textField
    }

    alertController.addTextField { [weak self] textField in
      textField.keyboardType = .emailAddress
      textField.isSecureTextEntry = true
      textField.placeholder = NSLocalizedString("Password", comment: "")

      let inputAccessoryView = TitleInputAccessoryView(title: NSLocalizedString("Enter your password", comment: ""))
      textField.inputAccessoryView = inputAccessoryView

      textField.addTarget(self, action: #selector(AuthorizationAlert.handleTextChange(_:)), for: .editingChanged)
      self?.passwordTextField = textField
    }

    let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .default) { [weak self] _ in

      guard let strongSelf = self else { return }

      guard
        let email = strongSelf.emailTextField?.text,
        let password = strongSelf.passwordTextField?.text
        else { return }

      switch strongSelf.authType {
      case .login:
        strongSelf.successCompletion?(.login(email: email, passowrd: password))
      case .registration:
        guard let name = strongSelf.nameTextField?.text else {
          return
        }

        strongSelf.successCompletion?(.registration(name: name, email: email, password: password))
      }
    }

    let cancelAction = UIAlertAction(title: nil, style: .cancel) { _ in
      print("Authorization canceled")
    }

    acceptAction.isEnabled = false
    self.acceptAction = acceptAction

    alertController.addAction(acceptAction)
    alertController.addAction(cancelAction)

    return alertController
  }

  func handleTextChange(_ textField: UITextField) {
    guard let acceptAction = self.acceptAction else { fatalError("no accept action") }

    switch authType {
    case .login:
      acceptAction.isEnabled =
        emailTextField?.text != nil && !(emailTextField!.text!.isEmpty) &&
        passwordTextField?.text != nil && !(passwordTextField!.text!.isEmpty)
    case .registration:
      acceptAction.isEnabled =
        nameTextField?.text != nil && !(nameTextField!.text!.isEmpty) &&
        emailTextField?.text != nil && !(emailTextField!.text!.isEmpty) &&
        passwordTextField?.text != nil && !(passwordTextField!.text!.isEmpty)
    }
  }
}
