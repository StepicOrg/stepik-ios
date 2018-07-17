//
//  AuthorizationGreetingAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit.UINavigationController

final class AuthorizationGreetingAssemblyImpl: BaseAssembly, AuthorizationGreetingAssembly {
    func module() -> UINavigationController {
        let greetingAuthViewController = GreetingAuthViewController()
        let navigationController = ClearNavigationViewController(rootViewController: greetingAuthViewController)
        greetingAuthViewController.router = AuthorizationGreetingRouterImpl(assemblyFactory: assemblyFactory, navigationController: navigationController)

        return navigationController
    }
}
