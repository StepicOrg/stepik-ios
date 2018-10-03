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
        let controller = TrainingCollectionViewController()
        let router = TrainingRouter(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = TrainingPresenter(
            view: controller,
            knowledgeGraph: serviceFactory.knowledgeGraphProvider.knowledgeGraph,
            router: router,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService,
            lessonsService: serviceFactory.lessonsService
        )
        controller.presenter = presenter

        return controller
    }
}
