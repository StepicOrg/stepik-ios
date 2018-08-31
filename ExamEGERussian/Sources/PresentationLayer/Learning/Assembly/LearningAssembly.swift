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
        let presenter = LearningPresenter(
            view: controller,
            knowledgeGraph: serviceFactory.knowledgeGraphProvider.knowledgeGraph,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService
        )
        controller.presenter = presenter

        return controller
    }
}
