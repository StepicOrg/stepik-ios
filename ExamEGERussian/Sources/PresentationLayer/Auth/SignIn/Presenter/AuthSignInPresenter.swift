//
//  ExamEmailAuthPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthSignInPresenter {
    func signIn(with email: String, password: String)
    func signUp()
    func cancel()
    func resetPassword()
}
