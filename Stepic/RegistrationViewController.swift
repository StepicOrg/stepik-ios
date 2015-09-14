//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import TextFieldEffects

class RegistrationViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: HoshiTextField!
    @IBOutlet weak var secondNameTextField: HoshiTextField!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var secondPasswordTextField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showTermsOfServicePressed(sender: UIButton) {
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
    }
    
    @IBAction func closePressed(sender: UIButton) {
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
    
    @IBAction func secondPasswordEditingChanged(sender: HoshiTextField) {
        if secondPasswordTextField.text != passwordTextField.text {
            secondPasswordTextField.borderActiveColor = UIColor.errorRedColor()
            secondPasswordTextField.becomeFirstResponder()
        } else {
            secondPasswordTextField.borderActiveColor =
            UIColor.stepicGreenColor()
            secondPasswordTextField.becomeFirstResponder()
        }
    }

    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
}

extension RegistrationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
