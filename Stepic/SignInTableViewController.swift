//
//  SignInTableViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD
import TextFieldEffects
import SafariServices

class SignInTableViewController: UITableViewController {

    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var socialLabel: UILabel!
    
    func setupLocalizations() {
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
        socialLabel.text = NSLocalizedString("SocialSignIn", comment: "")
        forgotPasswordButton.setTitle(NSLocalizedString("ForgotPassword", comment: ""), for: UIControlState())
    }
    
    var success : ((Void)->Void)? {
        return (navigationController as? AuthNavigationViewController)?.success
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalizations()
        passwordTextField.isSecureTextEntry = true
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(SignInTableViewController.tap))
        self.view.addGestureRecognizer(tapG)
        
        tableView.panGestureRecognizer.cancelsTouchesInView = false
        tableView.delaysContentTouches = false

//        print("table view cancels touches -> \(tableView.panGestureRecognizer.cancelsTouchesInView)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInTableViewController.didGetAuthentificationCode(_:)), name: NSNotification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func didGetAuthentificationCode(_ notification: Foundation.Notification) {
        print("entered didGetAuthentificationCode")

        //TODO: Implement WebControllerManager
        
        WebControllerManager.sharedManager.dismissWebControllerWithKey("social auth", animated: true, completion: {
            self.authentificateWithCode((notification as NSNotification).userInfo?["code"] as? String ?? "")
        }, error: {
            errorMessage in
            print(errorMessage)
        })        
    }
    
    func tap() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func authentificateWithCode(_ code: String) {
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        AuthManager.sharedManager.logInWithCode(code, 
            success: {
                t in
                AuthInfo.shared.token = t
                NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)
                ApiDataDownloader.sharedDownloader.getCurrentUser({
                    user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                    UIThread.performUI { 
                        self.navigationController?.dismiss(animated: true, completion: {
                            [weak self] in
                            self?.success?()
                        })
                    }
                    AnalyticsHelper.sharedHelper.changeSignIn()
                    AnalyticsHelper.sharedHelper.sendSignedIn()
                    }, failure: {
                        e in
                        print("successfully signed in, but could not get user")
                        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                        UIThread.performUI { 
                            self.navigationController?.dismiss(animated: true, completion: {
                                [weak self] in
                                self?.success?()
                            })
                        }
                })
            }, failure: {
                e in
                SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        })
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onSignInScreen, parameters: nil)
        
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        AuthManager.sharedManager.logInWithUsername(emailTextField.text!, password: passwordTextField.text!, 
            success: {
                t in
                AuthInfo.shared.token = t
                NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)
                ApiDataDownloader.sharedDownloader.getCurrentUser({
                    user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                    UIThread.performUI { 
                        self.navigationController?.dismiss(animated: true, completion: {
                            [weak self] in
                            self?.success?()
                        })
                    }
                    AnalyticsHelper.sharedHelper.changeSignIn()
                    AnalyticsHelper.sharedHelper.sendSignedIn()
                    }, failure: {
                        e in
                        print("successfully signed in, but could not get user")
                        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SignedIn", comment: ""))
                        UIThread.performUI{ 
                            self.navigationController?.dismiss(animated: true, completion: {
                                [weak self] in
                                self?.success?()
                            })
                        }
                })
            }, failure: {
                e in
                SVProgressHUD.showError(withStatus: NSLocalizedString("FailedToSignIn", comment: ""))
        })
    }
        
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString("\(StepicApplicationsInfo.stepicURL)/accounts/password/reset/", inController: self, 
            withKey: "reset password", allowsSafari: true, backButtonStyle: BackButtonStyle.done)        
//        UIApplication.sharedApplication().openURL(NSURL(string: "https://stepic.org/accounts/password/reset/")!)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: nil)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

