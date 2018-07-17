//
//  MainAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class MainAssemblyImpl: BaseAssembly, MainAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        let controller = MainViewController()
        let router = MainViewRouterImpl(assemblyFactory: assemblyFactory, navigationController: navigationController)
        let presenter = MainViewPresenterImpl(view: controller, router: router, userRegistrationService: serviceFactory.userRegistrationService())
        controller.presenter = presenter

        return controller
    }
}
