//
//  TopicsRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsRouterImpl: BaseRouter, TopicsRouter {
    func showAuth() {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authAssembly.greeting.module()
        })
    }

    func showLessonsForTopicWithId(_ id: String) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.lessonsAssembly.module(
                navigationController: navigationController,
                topicId: id
            )
        })
    }

    func showAdaptiveForTopicWithId(_ id: String) {
        if let module = assemblyFactory.adaptiveStepsAssembly.module(topicId: id) {
            pushViewController(derivedFrom: { _ in
                module
            })
        } else {
            navigationController?.presentAlert(
                withTitle: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("At this moment we couldn't show adaptive lessons. Please, try again later.", comment: "")
            )
        }
    }
}
