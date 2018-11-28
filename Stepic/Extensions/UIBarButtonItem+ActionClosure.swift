//
//  UIBarButtonItem+ActionClosure.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    private struct AssociatedObject {
        static var key = "action_closure_key"
    }

    var actionClosure: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObject.key) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            target = self
            action = #selector(didTapButton(sender:))
        }
    }

    @objc func didTapButton(sender: Any) {
        actionClosure?()
    }
}
