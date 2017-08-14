//
//  AuthNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class AuthNavigationViewController: UINavigationController {

    var success: (() -> Void)?
    var cancel: (() -> Void)?

    var canDismiss = true

    lazy var loggedSuccess: ((String) -> Void)? = {
        [weak self]
        provider in
        self?.success?()
        AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": provider as NSObject])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
