//
//  SignInViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.hidden = true
        // Do any additional setup after loading the view.
        
        self.signInButton.setRoundedCorners(cornerRadius: 9, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        
        let tapG = UITapGestureRecognizer(target: self, action: "tap")
        self.view.addGestureRecognizer(tapG)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.automaticallyAdjustsScrollViewInsets = false
        self.view.registerAsDodgeViewForMLInputDodger()
//        self.emailTextField.shiftHeightAsFirstResponderForMLInputDodger = 180.0
//        self.passwordTextField.shiftHeightAsFirstResponderForMLInputDodger = 180.0
        self.view.shiftHeightAsDodgeViewForMLInputDodger = 180.0;

    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        self.automaticallyAdjustsScrollViewInsets = false
//        self.view.registerAsDodgeViewForMLInputDodger()
//        self.emailTextField.shiftHeightAsFirstResponderForMLInputDodger = 180.0
//        self.passwordTextField.shiftHeightAsFirstResponderForMLInputDodger = 180.0
////        self.view.shiftHeightAsDodgeViewForMLInputDodger = 80.0;
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func socialPressed(sender: UIButton) {
        let urlString = "https://stepic.org/accounts/google/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode"
        UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
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
                self.performSegueWithIdentifier("signedInSegue", sender: self)
                AnalyticsHelper.sharedHelper.changeSignIn()
                AnalyticsHelper.sharedHelper.sendSignedIn()
                }, failure: {
                    e in
                    print("successfully signed in, but could not get user")
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
                    self.performSegueWithIdentifier("signedInSegue", sender: self)
            })
        }, failure: {
            e in
            self.errorLabel.hidden = false
            SVProgressHUD.showErrorWithStatus(NSLocalizedString("FailedToSignIn", comment: ""))
        })

    }

    @IBAction func registerPressed(sender: UIButton) {
        let registerUrl = "https://stepic.org/accounts/signup/?next=/"
        UIApplication.sharedApplication().openURL(NSURL(string: registerUrl)!)
    }
    
    @IBAction func textFieldDidBeginEditing(sender: UITextField) {
        if !errorLabel.hidden {
            errorLabel.hidden = true
        }
    }
    
    func tap() {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
