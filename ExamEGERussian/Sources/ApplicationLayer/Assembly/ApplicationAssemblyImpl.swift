//
//  ApplicationAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ApplicationAssemblyImpl: BaseAssembly, ApplicationAssembly {
    func module() -> ApplicationModule {
        if let savedModule = ApplicationModuleHolder.instance.applicationModule {
            return savedModule
        }

        let navigationController = UINavigationController()
        let controller = assemblyFactory.topicsAssembly.module(navigationController: navigationController)
        navigationController.setViewControllers([controller], animated: false)

        let router = AppRouter(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let applicationModule = ApplicationModule(router: router)

        ApplicationModuleHolder.instance.applicationModule = applicationModule

        return applicationModule
    }
}
