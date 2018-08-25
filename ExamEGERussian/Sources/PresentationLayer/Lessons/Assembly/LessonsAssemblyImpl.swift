//
//  LessonsAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonsAssemblyImpl: BaseAssembly, LessonsAssembly {
    func module(navigationController: UINavigationController, topicId: String) -> UIViewController {
        let controller = LessonsTableViewController()
        let router = LessonsRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )

        let knowledgeGraph = serviceFactory.knowledgeGraphProvider.knowledgeGraph
        let presenter = LessonsPresenterImpl(
            view: controller,
            router: router,
            topicId: topicId,
            knowledgeGraph: knowledgeGraph,
            lessonsService: serviceFactory.lessonsService,
            courseService: serviceFactory.courseService
        )
        controller.presenter = presenter
        controller.title = NSLocalizedString("LessonsViewControllerTitle", comment: "")

        return controller
    }
}
