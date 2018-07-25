//
//  TopicsAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsAssemblyImpl: BaseAssembly, TopicsAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        let controller = TopicsTableViewController()
        controller.presenter = TopicsPresenterImpl(
            view: controller,
            model: KnowledgeGraph(),
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService
        )

        return controller
    }
}
