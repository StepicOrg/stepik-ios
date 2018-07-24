//
//  RootNavigationManager.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class RootNavigationManager {

    // MARK: - Instance Properties

    private unowned let serviceComponents: ServiceComponents
    private weak var navigationController: UINavigationController?

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
            router: self,
            userRegistrationService: serviceComponents.userRegistrationService,
            graphService: serviceComponents.graphService
        )
        navigationController = UINavigationController(rootViewController: controller)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}

// MARK: - RootNavigationManager: TopicsRouter -

extension RootNavigationManager: TopicsRouter {
    func showLessonsForTopicWithId(_ id: String) {
        let controller = LessonsTableViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
