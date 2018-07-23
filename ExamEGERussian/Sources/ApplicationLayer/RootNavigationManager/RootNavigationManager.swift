//
//  RootNavigationManager.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

// MARK: RootNavigationManager

final class RootNavigationManager {

    // MARK: - Instance Variables

    private unowned let serviceComponents: ServiceComponents

    // MARK: Init

    init(serviceComponents: ServiceComponents) {
        self.serviceComponents = serviceComponents
    }

    // MARK: Public API

    func setup(with window: UIWindow) {
        let controller = TopicsTableViewController()
        controller.presenter = TopicsPresenterImpl(
            view: controller,
            model: KnowledgeGraph(),
            userRegistrationService: serviceComponents.userRegistrationService,
            graphService: serviceComponents.graphService
        )
        let navigationController = UINavigationController(rootViewController: controller)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}
