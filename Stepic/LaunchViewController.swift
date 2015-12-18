//
//  LaunchViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var dontHaveAccountLabel: UILabel!
    
    var signInController : SignInTableViewController?
    
    func setupLocalizations() {
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), forState: .Normal)
        signUpButton.setTitle(NSLocalizedString("SignUp", comment: ""), forState: .Normal)
        dontHaveAccountLabel.text = NSLocalizedString("DontHaveAccountQuestion", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalizations()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        signUpButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
        self.performSegueWithIdentifier("registrationSegue", sender: self)
//        let registerUrl = "https://stepic.org/accounts/signup/?next=/"
//        UIApplication.sharedApplication().openURL(NSURL(string: registerUrl)!)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "signInSegue" {
            let dvc = segue.destinationViewController as! SignInTableViewController
            signInController = dvc
        }
    }
}
