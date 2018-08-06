//
//  AuthSignUpRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthSignUpRouterImpl: BaseRouter, AuthSignUpRouter {
    func pop() {
        popToRootViewController()
    }
}
