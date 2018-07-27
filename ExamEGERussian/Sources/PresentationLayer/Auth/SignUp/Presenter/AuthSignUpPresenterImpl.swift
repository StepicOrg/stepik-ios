//
//  AuthSignUpPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthSignUpPresenterImpl: AuthSignUpPresenter {
    private weak var view: AuthSignUpView?
    private let router: AuthSignUpRouter

    init(view: AuthSignUpView, router: AuthSignUpRouter) {
        self.view = view
        self.router = router
    }
}
