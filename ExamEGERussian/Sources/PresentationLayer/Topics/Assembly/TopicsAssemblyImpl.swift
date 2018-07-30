//
//  TopicsAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsAssemblyImpl: BaseAssembly, TopicsAssembly {
    private let knowledgeGraph: KnowledgeGraph

    init(assemblyFactory: AssemblyFactory,
         serviceFactory: ServiceFactory,
         knowledgeGraph: KnowledgeGraph) {
        self.knowledgeGraph = knowledgeGraph
        super.init(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    func module(navigationController: UINavigationController) -> UIViewController {
        let controller = TopicsTableViewController()
        let router = TopicsRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        controller.presenter = TopicsPresenterImpl(
            view: controller,
            knowledgeGraph: knowledgeGraph,
            router: router,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService
        )

        return controller
    }
}
