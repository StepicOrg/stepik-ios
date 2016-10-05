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
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
        signUpButton.setTitle(NSLocalizedString("SignUp", comment: ""), for: UIControlState())
        dontHaveAccountLabel.text = NSLocalizedString("DontHaveAccountQuestion", comment: "")
    }
    
    var cancel : ((Void)->Void)? {
        return (navigationController as? AuthNavigationViewController)?.cancel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalizations()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.stepicGreenColor()
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        signUpButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)    
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
        self.navigationController?.dismiss(animated: true, completion: {
            [weak self] in
            self?.cancel?()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInSegue" {
            let dvc = segue.destination as! SignInTableViewController
            signInController = dvc
        }
    }
}
