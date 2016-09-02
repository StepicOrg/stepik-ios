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
    
    var cancel : (Void->Void)? {
        return (navigationController as? AuthNavigationViewController)?.cancel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalizations()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        navigationController?.navigationBar.opaque = true
        navigationController?.navigationBar.tintColor = UIColor.stepicGreenColor()
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        signUpButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)    
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInPressed(sender: UIButton) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.onLaunchScreen, parameters: nil)
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
        self.performSegueWithIdentifier("registrationSegue", sender: self)
        AnalyticsReporter.reportEvent(AnalyticsEvents.SignUp.onLaunchScreen, parameters: nil)
    }

    @IBAction func сlosePressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            [weak self] in
            self?.cancel?()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signInSegue" {
            let dvc = segue.destinationViewController as! SignInTableViewController
            signInController = dvc
        }
    }
}
