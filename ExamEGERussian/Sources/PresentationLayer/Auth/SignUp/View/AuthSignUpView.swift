//
//  AuthSignUpView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum AuthSignUpResult {
    case success, error, badConnection
}

enum AuthSignUpState {
    case normal, loading, validationError(message: String)
}

protocol AuthSignUpView: class {
    var state: AuthSignUpState { get set }

    func update(with result: AuthSignUpResult)
}
