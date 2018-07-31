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
    private let knowledgeGraph = KnowledgeGraph()

    // MARK: Init

    init(serviceComponents: ServiceComponents) {
        self.serviceComponents = serviceComponents
    }

    // MARK: Public API

    func setup(with window: UIWindow) {
        let controller = TopicsTableViewController()
        controller.presenter = TopicsPresenterImpl(
            view: controller,
            knowledgeGraph: knowledgeGraph,
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
        let presenter = LessonsPresenterImpl(
            view: controller,
            router: self,
            topicId: id,
            knowledgeGraph: knowledgeGraph,
            lessonsService: serviceComponents.lessonsService,
            courseService: serviceComponents.courseService,
            enrollmentService: serviceComponents.enrollmentService
        )
        controller.presenter = presenter
        controller.title = knowledgeGraph[id]?.key.title

        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - RootNavigationManager: LessonsRouter -

extension RootNavigationManager: LessonsRouter {
    func showStepsForLesson(_ lesson: LessonPlainObject) {
        let controller = StepsViewController(
            lesson: lesson,
            stepsService: serviceComponents.stepsService
        )

        navigationController?.pushViewController(controller, animated: true)
    }
}
