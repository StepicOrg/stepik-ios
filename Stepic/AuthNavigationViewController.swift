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
        case social
        case email(email: String?)
        case registration
    }

    var success: (() -> Void)?
    var cancel: (() -> Void)?

    var canDismiss = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Maybe create Router layer?
    func dismissAfterSuccess() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.success?()
        })
    }

    func route(from fromController: Controller, to toController: Controller?) {
        if toController == nil {
            // Close action
            switch fromController {
            case .registration:
                popViewController(animated: true)
            default:
                if canDismiss {
                    dismiss(animated: true, completion: { [weak self] in
                        self?.cancel?()
                    })
                }
            }

            return
        }

        var vcs = viewControllers

        switch toController! {
        case .registration:
            // Push registration controller
            let vc = ControllerHelper.instantiateViewController(identifier: "Registration", storyboardName: "Auth")
            pushViewController(vc, animated: true)
        case .email(let email):
            // Replace top view controller
            let vc = ControllerHelper.instantiateViewController(identifier: "EmailAuth", storyboardName: "Auth")
            if let vc = vc as? EmailAuthViewController {
                vc.prefilledEmail = email
                vcs[vcs.count - 1] = vc
                setViewControllers(vcs, animated: true)
            }
        case .social:
            // Replace top view controller
            vcs[vcs.count - 1] = ControllerHelper.instantiateViewController(identifier: "SocialAuth", storyboardName: "Auth")
            setViewControllers(vcs, animated: true)
        }
    }

    // Disable landscape for iPhones
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return DeviceInfo.current.isPad ? .all : .portrait
    }

    override var shouldAutorotate: Bool {
        return DeviceInfo.current.isPad
    }
}
