//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import TextFieldEffects
import SVProgressHUD

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var closeBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var firstNameTextField: HoshiTextField!
    
    @IBOutlet weak var lastNameTextField: HoshiTextField!
    
    @IBOutlet weak var emailTextField: HoshiTextField!
    
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    @IBOutlet weak var visiblePasswordButton: UIButton!
    
    var passwordSecure = false {
        didSet {
            visiblePasswordButton.setImage(passwordSecure ? Images.visibleImage : Images.visibleFilledImage, forState: UIControlState.Normal)
            passwordTextField.secureTextEntry = passwordSecure
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        closeBarButtonItem.tintColor = UIColor.stepicGreenColor()
        signUpButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        
        passwordTextField.delegate = self
        visiblePasswordButton.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        signUpToStepic()
    }
    
    func signUpToStepic() {
        let email = emailTextField.text ?? ""
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        SVProgressHUD.show()
        AuthentificationManager.sharedManager.signUpWith(firstName, lastname: lastName, email: email, password: password, success: {
            AuthentificationManager.sharedManager.logInWithUsername(email, password: password, 
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
            }, error: {
                errormsg in
                UIThread.performUI{SVProgressHUD.showErrorWithStatus(errormsg)}
        })
    }
    
    @IBAction func visiblePasswordButtonPressed(sender: AnyObject) {
        passwordSecure = !passwordSecure
    }
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

extension RegistrationViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        print("did begin")
        passwordSecure = true
        if textField == passwordTextField {
            visiblePasswordButton.hidden = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("did end")
        passwordSecure = true
        if textField == passwordTextField && textField.text == "" {
            visiblePasswordButton.hidden = true
        }
    }    
}
