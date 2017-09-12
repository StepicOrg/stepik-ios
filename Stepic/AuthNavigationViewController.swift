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
    }
}
