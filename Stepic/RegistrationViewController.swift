//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import TextFieldEffects

class RegistrationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        signUpToStepic()
    }

    func signUpToStepic() {
        AuthentificationManager.sharedManager.signUpWith("1223", lastname: "123", email: "qwewrqwer", password: "12332!", success: {
                print("sucess!")
            }, error: {
            errormsg in
            print("registration error -> \(errormsg)")
        })
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
