//
//  AuthorizationPresentable.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

@objc protocol AuthorizationPresentable: class {
    func showAuthorization(animated: Bool)
}

extension AuthorizationPresentable {
    func showAuthorization() {
        showAuthorization(animated: true)
    }
}
