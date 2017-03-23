//
//  AdaptiveAuthViewController.swift
//  StepicAdaptiveCourse
//
//  Created by Vladislav Kiryukhin on 23.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveAuthViewController: UIViewController {

    @IBAction func onSignInButtonClick(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthNavigation")
        (vc as! AuthNavigationViewController).success = { [weak self] in
            self?.performSegue(withIdentifier: "openMainScreen", sender: nil)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if AuthInfo.shared.isAuthorized {
            UIThread.performUI {
                self.performSegue(withIdentifier: "openMainScreen", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

