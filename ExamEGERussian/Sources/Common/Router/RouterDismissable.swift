//
//  RouterDismissable.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

@objc protocol RouterDismissable: class {
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

extension RouterDismissable {
    func dismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
