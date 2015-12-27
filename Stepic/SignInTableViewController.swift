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
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), forState: .Normal)
        socialLabel.text = NSLocalizedString("SocialSignIn", comment: "")
        forgotPasswordButton.setTitle(NSLocalizedString("ForgotPassword", comment: ""), forState: .Normal)
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalizations()
        passwordTextField.secureTextEntry = true
        emailTextField.keyboardType = .EmailAddress
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
        
        let tapG = UITapGestureRecognizer(target: self, action: "tap")
        self.view.addGestureRecognizer(tapG)
        
        tableView.panGestureRecognizer.cancelsTouchesInView = false
        tableView.delaysContentTouches = false

//        print("table view cancels touches -> \(tableView.panGestureRecognizer.cancelsTouchesInView)")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetAuthentificationCode:", name: "ReceivedAuthorizationCodeNotification", object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func didGetAuthentificationCode(notification: NSNotification) {
        print("entered didGetAuthentificationCode")

        //TODO: Implement WebControllerManager
        
        WebControllerManager.sharedManager.dismissWebControllerWithKey("social auth", animated: true, completion: {
            self.authentificateWithCode(notification.userInfo?["code"] as? String ?? "")
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func authentificateWithCode(code: String) {
        SVProgressHUD.showWithStatus("", maskType: SVProgressHUDMaskType.Clear)
        AuthentificationManager.sharedManager.logInWithCode(code, 
            success: {
                t in
                StepicAPI.shared.token = t
                ApiDataDownloader.sharedDownloader.getCurrentUser({
                    user in
                    StepicAPI.shared.user = user
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                    UIThread.performUI({self.performSegueWithIdentifier("signedInSegue", sender: self)})
                    AnalyticsHelper.sharedHelper.changeSignIn()
                    AnalyticsHelper.sharedHelper.sendSignedIn()
                    }, failure: {
                        e in
                        print("successfully signed in, but could not get user")
                        SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                        UIThread.performUI({self.performSegueWithIdentifier("signedInSegue", sender: self)})
                })
            }, failure: {
                e in
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("FailedToSignIn", comment: ""))
        })
    }
    
    @IBAction func signInPressed(sender: UIButton) {
        SVProgressHUD.showWithStatus("", maskType: SVProgressHUDMaskType.Clear)
        AuthentificationManager.sharedManager.logInWithUsername(emailTextField.text!, password: passwordTextField.text!, 
            success: {
                t in
                StepicAPI.shared.token = t
                ApiDataDownloader.sharedDownloader.getCurrentUser({
                    user in
                    StepicAPI.shared.user = user
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                    UIThread.performUI({self.performSegueWithIdentifier("signedInSegue", sender: self)})
                    AnalyticsHelper.sharedHelper.changeSignIn()
                    AnalyticsHelper.sharedHelper.sendSignedIn()
                    }, failure: {
                        e in
                        print("successfully signed in, but could not get user")
                        SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                        UIThread.performUI({self.performSegueWithIdentifier("signedInSegue", sender: self)})
                })
            }, failure: {
                e in
                SVProgressHUD.showErrorWithStatus(NSLocalizedString("FailedToSignIn", comment: ""))
        })
    }
        
    @IBAction func forgotPasswordPressed(sender: UIButton) {
        WebControllerManager.sharedManager.presentWebControllerWithURLString("https://stepic.org/accounts/password/reset/", inController: self, 
            withKey: "reset password", allowsSafari: true, backButtonStyle: BackButtonStyle.Done)        
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReceivedAuthorizationCodeNotification", object: nil)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

