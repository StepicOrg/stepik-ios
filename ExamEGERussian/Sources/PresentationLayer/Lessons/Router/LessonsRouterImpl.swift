//
//  LessonsRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonsRouterImpl: BaseRouter, LessonsRouter {
    func showStepsForLesson(_ lesson: LessonPlainObject) {
        pushViewController(derivedFrom: { navigationController in
            assemblyFactory.stepsAssembly.module(
                navigationController: navigationController,
                lesson: lesson
            )
        })
    }
}
