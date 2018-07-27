//
//  AuthorizationSignUpAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthSignUpAssemblyImpl: BaseAssembly, AuthSignUpAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        let controller = AuthSignUpViewController()
        let router = AuthSignUpRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = AuthSignUpPresenterImpl(
            view: controller,
            router: router,
            userRegistrationService: serviceFactory.userRegistrationService
        )
        controller.presenter = presenter

        return controller
    }
}
