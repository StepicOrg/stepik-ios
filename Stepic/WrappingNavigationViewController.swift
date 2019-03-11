//
//  StyledNavigationController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//
import UIKit

class WrappingNavigationViewController: StyledNavigationController {
    private var onDismissAction: (() -> Void)?

    convenience init(wrappedViewController: UIViewController, title: String? = nil, onDismiss: (() -> Void)? = nil) {
        self.init(rootViewController: wrappedViewController)

        wrappedViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelPressed))
        wrappedViewController.navigationItem.title = title

        onDismissAction = onDismiss
    }

    @objc private func cancelPressed() {
        self.dismiss(animated: true, completion: onDismissAction)
    }
}
