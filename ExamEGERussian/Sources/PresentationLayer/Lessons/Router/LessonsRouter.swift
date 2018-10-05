//
//  LessonsRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonsRouter: BaseRouter, LessonsRouterProtocol {
    func showTheory(lesson: LessonPlainObject) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.stepsAssembly.standart.module(
                navigationController: navigationController,
                lesson: lesson
            )
        })
	}

    func showPractice(courseId: Int) {
        pushViewController(derivedFrom: { _ in
            assemblyFactory.stepsAssembly.adaptive.module(courseId: courseId)
        })
    }
}
