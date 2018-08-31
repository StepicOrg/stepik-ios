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

        let tabBarController = UITabBarController()
        // Hides dark shadow on navigation bar during transition.
        tabBarController.view.backgroundColor = .white

        let learningNavigationController = makeLearningController()
        let trainingNavigationController = makeTrainingController()

        tabBarController.setViewControllers(
            [learningNavigationController, trainingNavigationController],
            animated: false
        )
        tabBarController.selectedIndex = 0

        let router = AppRouter(
            tabBarController: tabBarController,
            navigationController: learningNavigationController,
            assemblyFactory: assemblyFactory
        )
        let applicationModule = ApplicationModule(router: router)

        ApplicationModuleHolder.instance.applicationModule = applicationModule

        return applicationModule
    }

    private func makeLearningController() -> UINavigationController {
        let navigationController = UINavigationController()
        let controller = assemblyFactory.learningAssembly.makeModule(
            navigationController: navigationController
        )
        controller.title = NSLocalizedString("LearningTabTitle", comment: "")
        controller.tabBarItem = UITabBarItem(
            title: controller.title,
            image: UIImage(named: "learning-tab-bar"),
            tag: 0
        )
        navigationController.setViewControllers([controller], animated: false)

        return navigationController
    }

    private func makeTrainingController() -> UINavigationController {
        let navigationController = UINavigationController()
        let controller = assemblyFactory.trainingAssembly.makeModule(
            navigationController: navigationController
        )
        navigationController.setViewControllers([controller], animated: false)

        controller.title = NSLocalizedString("TrainingTabTitle", comment: "")
        controller.tabBarItem = UITabBarItem(
            title: controller.title,
            image: UIImage(named: "training-tab-bar"),
            tag: 1
        )
        navigationController.setViewControllers([controller], animated: false)

        return navigationController
    }
}
