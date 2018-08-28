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
        tabBarController.selectedIndex = 1

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
        guard let controller = assemblyFactory.topicsAssembly.module(
            navigationController: navigationController
        ) as? TopicsTableViewController else {
            fatalError("TopicsTableViewController expected")
        }

        controller.title = NSLocalizedString("LearningTabTitle", comment: "")
        controller.tabBarItem = UITabBarItem(
            title: controller.title,
            image: UIImage(named: "learning-tab-bar"),
            tag: 0
        )
        controller.presenter.selectSegment(at: 0)
        navigationController.setViewControllers([controller], animated: false)

        return navigationController
    }

    private func makeTrainingController() -> UINavigationController {
        let dataSource = TrainingTopicsViewDataSource()
        let delegate = TrainingTopicsViewDelegate()
        let controller = TopicsViewController(dataSource: dataSource, delegate: delegate)
        let navigationController = UINavigationController()
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
