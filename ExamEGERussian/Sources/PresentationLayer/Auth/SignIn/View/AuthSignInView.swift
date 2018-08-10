//
//  AuthSignInView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum AuthSignInResult {
    case success, error, manyAttempts, badConnection
}

enum AuthSignInState {
    case normal, loading, validationError, existingEmail
}

protocol AuthSignInView: class {
    var state: AuthSignInState { get set }

    func update(with result: AuthSignInResult)
}
