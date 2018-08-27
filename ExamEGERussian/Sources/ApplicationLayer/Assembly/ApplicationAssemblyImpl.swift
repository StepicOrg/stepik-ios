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

        let learningNavigationController = UINavigationController()
        let learningController = assemblyFactory.topicsAssembly.module(
            navigationController: learningNavigationController
        )
        learningController.title = NSLocalizedString("LearningTabTitle", comment: "")
        learningController.tabBarItem = UITabBarItem(
            title: learningController.title,
            image: UIImage(named: "learning-tab-bar"),
            tag: 0
        )
        learningNavigationController.setViewControllers([learningController], animated: false)

        let trainingNavigationController = UINavigationController()
        let trainingController = assemblyFactory.topicsAssembly.module(
            navigationController: trainingNavigationController
        )
        trainingController.title = NSLocalizedString("TrainingTabTitle", comment: "")
        trainingController.tabBarItem = UITabBarItem(
            title: trainingController.title,
            image: UIImage(named: "training-tab-bar"),
            tag: 1
        )
        trainingNavigationController.setViewControllers([trainingController], animated: false)

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
}
