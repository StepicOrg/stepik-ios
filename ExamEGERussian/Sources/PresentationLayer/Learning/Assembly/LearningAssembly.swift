//
//  LearningAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LearningAssembly: BaseAssembly, LearningAssemblyProtocol {
    func makeModule(navigationController: UINavigationController) -> UIViewController {
        let controller = LearningTableViewController()
        let router = LearningRouter(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = LearningPresenter(
            view: controller,
            router: router,
            knowledgeGraph: serviceFactory.knowledgeGraphProvider.knowledgeGraph,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService,
            lessonsService: serviceFactory.lessonsService,
            stepsService: serviceFactory.stepsService,
            courseService: serviceFactory.courseService
        )
        controller.presenter = presenter

        return controller
    }
}
