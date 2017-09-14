//
//  AuthNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class AuthNavigationViewController: UINavigationController {

    enum Controller {
        case social, email, registration
    }

    var success: (() -> Void)?
    var cancel: (() -> Void)?

    var canDismiss = true

    lazy var loggedSuccess: ((String) -> Void)? = { [weak self] provider in
        self?.success?()
        AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": provider as NSObject])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Maybe create Router layer?
    func route(from fromController: Controller, to toController: Controller?) {
        if toController == nil {
            // Close action
            if fromController == .registration {
                popViewController(animated: true)
            } else {
                if canDismiss {
                    dismiss(animated: true, completion: { [weak self] in
                        self?.cancel?()
                    })
                }
            }

            return
        }

        if toController == .registration {
            // Push registration controller
            let vc = ControllerHelper.instantiateViewController(identifier: "Registration", storyboardName: "Auth")
            pushViewController(vc, animated: true)
        } else {
            // Replace top view controller
            let vcId = toController == .email ? "EmailAuth" : "SocialAuth"
            var vcs = viewControllers
            vcs[vcs.count - 1] = ControllerHelper.instantiateViewController(identifier: vcId, storyboardName: "Auth")
            setViewControllers(vcs, animated: true)
        }
    }
}
