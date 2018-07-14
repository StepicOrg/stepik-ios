//
//  RouterDismissable.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public protocol RouterDismissable: class {
    func dismiss(completion: (() -> Void)?)
}

public extension RouterDismissable {
    func dismiss() {
        dismiss(completion: nil)
    }
}
