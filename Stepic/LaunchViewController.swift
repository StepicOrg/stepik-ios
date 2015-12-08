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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        signUpButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
        let registerUrl = "https://stepic.org/accounts/signup/?next=/"
        UIApplication.sharedApplication().openURL(NSURL(string: registerUrl)!)
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
