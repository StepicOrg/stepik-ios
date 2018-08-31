//
//  TrainingAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TrainingAssembly: BaseAssembly, TrainingAssemblyProtocol {
    func makeModule(navigationController: UINavigationController) -> UIViewController {
        let source = TrainingTopicsCollectionSource()
        let controller = TrainingViewController(source: source)
        let router = TrainingRouter(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = TrainingPresenter(
            view: controller,
            knowledgeGraph: serviceFactory.knowledgeGraphProvider.knowledgeGraph,
            router: router,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService
        )
        controller.presenter = presenter
        source.didSelectTopic = presenter.selectTopic

        return controller
    }
}
