//
//  TrainingRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TrainingRouter: BaseRouter, TrainingRouterProtocol {
    func showAuth() {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authAssembly.greeting.module()
        })
    }

    func showTheory(lesson: LessonPlainObject) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.stepsAssembly.standart.module(
                navigationController: navigationController,
                lesson: lesson
            )
        })
    }

    func showPractice(courseId: String) {
        if let id = Int(courseId) {
            pushViewController(derivedFrom: { _ in
                assemblyFactory.stepsAssembly.adaptive.module(courseId: id)
            })
        } else {
            navigationController?.presentAlert(
                withTitle: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("NoAdaptiveModuleError", comment: "")
            )
        }
    }
}
