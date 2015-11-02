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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.hidden = true
        // Do any additional setup after loading the view.
        
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
    
    @IBAction func signInPressed(sender: UIButton) {
        
        SVProgressHUD.show()
        AuthentificationManager.sharedManager.logInWithUsername(emailTextField.text!, password: passwordTextField.text!, 
            
        success: {
            t in
            StepicAPI.shared.token = t
            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("SignedIn", comment: ""))
            self.performSegueWithIdentifier("signedInSegue", sender: self)
        }, failure: {
            e in
            self.errorLabel.hidden = false
            SVProgressHUD.showErrorWithStatus(NSLocalizedString("FailedToSignIn", comment: ""))
        })

    }

    @IBAction func registerPressed(sender: UIButton) {
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
