//
//  StepRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepRouter: StepRouterProtocol {
    private weak var viewController: UIViewController?
    private let authAssembly: AuthAssembly

    init(viewController: UIViewController, authAssembly: AuthAssembly) {
        self.viewController = viewController
        self.authAssembly = authAssembly
    }

    func showAuth() {
        viewController?.show(authAssembly.greeting.module(), sender: nil)
    }
}
