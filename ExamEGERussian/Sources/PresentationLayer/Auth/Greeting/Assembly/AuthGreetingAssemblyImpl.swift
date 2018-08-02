//
//  AuthorizationGreetingAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit.UINavigationController

final class AuthGreetingAssemblyImpl: BaseAssembly, AuthGreetingAssembly {
    func module() -> UINavigationController {
        let controller = AuthGreetingViewController()
        let navigationController = ClearNavigationViewController(rootViewController: controller)
        controller.router = AuthGreetingRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )

        return navigationController
    }
}
