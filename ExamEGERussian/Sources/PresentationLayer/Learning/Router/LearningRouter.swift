//
//  LearningRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LearningRouter: BaseRouter, LearningRouterProtocol {
    func showLessons(topicId: String) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.lessonsAssembly.module(
                navigationController: navigationController,
                topicId: topicId
            )
        })
    }
}
