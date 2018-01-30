//
//  MenuSplitViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MenuSplitViewController: UISplitViewController {

    fileprivate var messageView: TVAlertView?

    // MARK: Properties

    /**
     Set to true from `updateFocusToDetailViewController()` to indicate that
     the detail view controller should be the preferred focused view when
     this view controller is next queried.
     */
    private var preferDetailViewControllerOnNextFocusUpdate = false

    // MARK: UIFocusEnvironment

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        let environments: [UIFocusEnvironment]

        /*
         Check if a request has been made to move the focus to the detail
         view controller.
         */
        if preferDetailViewControllerOnNextFocusUpdate, let detailViewController = viewControllers.last {
            environments = detailViewController.preferredFocusEnvironments
            preferDetailViewControllerOnNextFocusUpdate = false
        } else {
            environments = super.preferredFocusEnvironments
        }

        return environments
    }

    // MARK: Focus helpers

    /**
     Called from a containing `MenuTableViewController` whenever the user
     selects a table view row in a master view controller.
     */
    func updateFocusToDetailViewController() {
        preferDetailViewControllerOnNextFocusUpdate = true

        /*
         Trigger the focus system to re-query the view hierarchy for preferred
         focused views.
         */
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
}

extension MenuSplitViewController: MenuSplitView {

    func showMessageOver(_ message: String, buttonTitle: String, buttonAction: @escaping () -> Void) {
        messageView = TVAlertView(frame: self.view.bounds, color: .gray)
        messageView!.setup(title: message, buttonTitle: buttonTitle, action: buttonAction)

        self.view.addSubview(messageView!)
    }

    func showMessageOver(_ message: String) {
        messageView = TVAlertView(frame: self.view.bounds, color: .gray)
        messageView!.setup(title: message)

        self.view.addSubview(messageView!)
    }

    func hideMessageOver() {
        messageView?.removeFromSuperview()
    }
}
