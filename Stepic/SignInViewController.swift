//
//  SignInViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import TextFieldEffects

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    var prefilledEmail: String?

    fileprivate func setupLocalizations() {
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
        forgotPasswordButton.setTitle(NSLocalizedString("ForgotPassword", comment: ""), for: UIControlState())
    }

    var success: ((String) -> Void)? {
        return (navigationController as? AuthNavigationViewController)?.loggedSuccess
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func setupTextFields() {
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .send

        emailTextField.delegate = self
        passwordTextField.delegate = self

        passwordTextField.isSecureTextEntry = true

        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no

        emailTextField.addTarget(self, action: #selector(RegistrationViewController.textFieldDidChange(textField:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(RegistrationViewController.textFieldDidChange(textField:)), for: .editingChanged)
    }

    func textFieldDidChange(textField: UITextField) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.Fields.typing, parameters: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalizations()

        setupTextFields()

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        let titleImageView = UIImageView(image: Images.logotypes.text.green.navigation)
        titleImageView.contentMode = .scaleAspectFit

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        titleImageView.frame = titleView.bounds
        titleView.addSubview(titleImageView)

        navigationItem.titleView = titleView

        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        prefill()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func prefill() {
        guard let email = self.prefilledEmail, email != "" else { return }

        emailTextField.text = email

        let alert = UIAlertController(title: nil, message: NSLocalizedString("SocialSignupWithExistingEmail", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            _ in
            self.passwordTextField.becomeFirstResponder()
        }))
        present(alert, animated: true, completion: nil)
    }

    fileprivate func signIn() {
        SVProgressHUD.show(withStatus: "")
        _ = AuthManager.sharedManager.logInWithUsername(emailTextField.text!, password: passwordTextField.text!, success: {
            t in
            AuthInfo.shared.token = t
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)
            _ = ApiDataDownloader.stepics.retrieveCurrentUser(success: {
                user in
                AuthInfo.shared.user = user
                User.removeAllExcept(user)
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                UIThread.performUI {
                    [weak self] in
                    self?.navigationController?.dismiss(animated: true, completion: {
                        [weak self] in
                        self?.success?("password")
                    })
                }
            }, error: {
                _ in
                print("successfully signed in, but could not get user")
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                UIThread.performUI {
                    [weak self] in
                    self?.navigationController?.dismiss(animated: true, completion: {
                        [weak self] in
                        self?.success?("password")
                    })
                }
            })
        }, failure: {
            e in
            var hudMessage: String = NSLocalizedString("FailedToSignIn", comment: "")
            switch e {
            case .other(error: _, code: let code, message: _):
                if code == 429 {
                    hudMessage = "Too many attempts. Please, try later."
                }
                break
            default:
                break
            }
            SVProgressHUD.showError(withStatus: hudMessage)
        })
    }

    @IBAction func signInPressed(_ sender: UIButton) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onSignInScreen, parameters: ["LoginInteractionType": "button"])
        signIn()
    }

    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString("\(StepicApplicationsInfo.stepicURL)/accounts/password/reset/", inController: self,
                                                                             withKey: "reset password", allowsSafari: true, backButtonStyle: BackButtonStyle.done)
    }

    deinit {
        print("did deinit SignInViewController")
    }
}

extension SignInViewController : UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.Fields.tap, parameters: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }

        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.nextButton, parameters: nil)
            AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onSignInScreen, parameters: ["LoginInteractionType": "ime"])
            signIn()
            return true
        }

        return true
    }
}
