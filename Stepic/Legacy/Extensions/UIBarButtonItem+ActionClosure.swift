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
    var actionClosure: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &AssociatedObject.key) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.target = self
            self.action = #selector(self.didTapButton(sender:))
        }
    }

    @objc
    private func didTapButton(sender: Any) {
        self.actionClosure?()
    }

    private enum AssociatedObject {
        static var key = "action_closure_key"
    }
}
