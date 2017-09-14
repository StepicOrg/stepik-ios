//
//  LaunchViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

class LaunchViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dontHaveAccountLabel: UILabel!
    @IBOutlet weak var continueWithLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var logotypeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logotypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logotypeImageView: UIImageView!

    var signInController: SignInViewController?

    func setupLocalizations() {
        signInButton.setTitle(NSLocalizedString("SignInByEmail", comment: ""), for: .normal)
        signUpButton.setTitle(NSLocalizedString("SignUp", comment: ""), for: UIControlState())
        dontHaveAccountLabel.text = NSLocalizedString("DontHaveAccountQuestion", comment: "")
        continueWithLabel.text = NSLocalizedString("SocialSignIn", comment: "")
        orLabel.text = NSLocalizedString("or", comment: "")
    }

    var cancel : (() -> Void)? {
        return (navigationController as? AuthNavigationViewController)?.cancel
    }

    var canDismiss: Bool {
        return (navigationController as? AuthNavigationViewController)?.canDismiss ?? true
    }

    var success: ((String) -> Void)? {
        return (navigationController as? AuthNavigationViewController)?.loggedSuccess
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalizations()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.stepicGreenColor
        navigationController?.navigationBar.barTintColor = UIColor.white

        dismissButton.isHidden = !canDismiss
        signInButton.setStepicGreenStyle()
        signUpButton.setStepicWhiteStyle()

        NotificationCenter.default.addObserver(self, selector: #selector(LaunchViewController.didGetAuthCode(_:)), name: NSNotification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInPressed(_ sender: UIButton) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onLaunchScreen, parameters: nil)
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "registrationSegue", sender: self)
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.onLaunchScreen, parameters: nil)
    }

    @IBAction func сlosePressed(_ sender: AnyObject) {
        if canDismiss {
            self.navigationController?.dismiss(animated: true, completion: {
                [weak self] in
                self?.cancel?()
            })
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if size.height <= 320 {
            logotypeImageView.isHidden = true
        } else {
            logotypeImageView.isHidden = false
        }
    }

    func didGetAuthCode(_ notification: Foundation.Notification) {
        print("entered didGetAuthentificationCode")

        WebControllerManager.sharedManager.dismissWebControllerWithKey("social auth", animated: true, completion: {
            self.auth(code: (notification as NSNotification).userInfo?["code"] as? String ?? "")
        }, error: {
            errorMessage in
            print(errorMessage)
        })
    }

    func auth(code: String) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.Social.codeReceived, parameters: nil)
        SVProgressHUD.show(withStatus: "")
        _ = AuthManager.sharedManager.logInWithCode(code, success: {
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
                        self?.success?("social")
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
                        self?.success?("social")
                    })
                }
            })
        }, failure: {
            _ in
            SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "socialNetworksEmbedSegue" {
            let dvc = segue.destination as? SocialNetworksViewController
            dvc?.dismissBlock = {
                [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: {
                    [weak self] in
                    self?.success?("social")
                })
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("did deinit SignInViewController")
    }

}
