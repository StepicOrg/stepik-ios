//
//  LessonsAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonsAssemblyImpl: BaseAssembly, LessonsAssembly {
    private let knowledgeGraph: KnowledgeGraph

    init(assemblyFactory: AssemblyFactory,
         serviceFactory: ServiceFactory,
         knowledgeGraph: KnowledgeGraph) {
        self.knowledgeGraph = knowledgeGraph
        super.init(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    func module(navigationController: UINavigationController, topicId: String) -> UIViewController {
        let controller = LessonsTableViewController()
        let router = LessonsRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = LessonsPresenterImpl(
            view: controller,
            router: router,
            topicId: topicId,
            knowledgeGraph: knowledgeGraph,
            lessonsService: serviceFactory.lessonsService,
            courseService: serviceFactory.courseService,
            enrollmentService: serviceFactory.enrollmentService
        )
        controller.presenter = presenter
        controller.title = knowledgeGraph[topicId]?.key.title

        return controller
    }
}
