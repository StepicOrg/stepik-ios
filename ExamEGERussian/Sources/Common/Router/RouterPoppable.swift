//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UIViewController

@objc protocol RouterPoppable: class {
    func pop(animated: Bool)
    func popToRootViewController(animated: Bool)
    func popToViewController(_ viewController: UIViewController, animated: Bool)
}

extension RouterPoppable {
    func pop() {
        pop(animated: true)
    }

    func popToRootViewController() {
        popToRootViewController(animated: true)
    }

    func popToViewController(_ viewController: UIViewController) {
        popToViewController(viewController, animated: true)
    }
}
