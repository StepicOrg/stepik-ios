//
//  SignInViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 21/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var success : ((Void)->Void)? {
        return (navigationController as? AuthNavigationViewController)?.success
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalizations()
        passwordTextField.isSecureTextEntry = true
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        signInButton.layer.masksToBounds = true
        signInButton.layer.cornerRadius = 20
        
    }
    
    
    func setupLocalizations() {
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
    }
    
    
    @IBAction func signInPressed(_ sender: UIButton) {
        
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onSignInScreen, parameters: nil)
        
        _ = AuthManager.sharedManager
            .logInWithUsername(emailTextField.text!,
                               password: passwordTextField.text!,
                               success: { t in
                                AuthInfo.shared.token = t
                                ApiDataDownloader.sharedDownloader.getCurrentUser({ user in
                                    
                                    AuthInfo.shared.user = user
                                    User.removeAllExcept(user)
                                    UIThread.performUI {
                                        self.navigationController?.dismiss(animated: true, completion: {
                                            [weak self] in
                                            self?.success?()
                                        })
                                    }
                                    AnalyticsHelper.sharedHelper.changeSignIn()
                                    AnalyticsHelper.sharedHelper.sendSignedIn()
                                }, failure: { e in
                                    
                                    print("successfully signed in, but could not get user")
                                    UIThread.performUI{
                                        self.navigationController?.dismiss(animated: true, completion: {
                                            [weak self] in
                                            self?.success?()
                                        })
                                    }
                                })
            }, failure: { e in
                print(e)
            })
    }
    
}
