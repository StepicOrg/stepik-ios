//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepAssembly: class {
    func module(lesson: LessonPlainObject, step: StepPlainObject,
                stepPresenterDelegate: StepPresenterDelegate?) -> UIViewController
}

extension StepAssembly {
    func module(lesson: LessonPlainObject, step: StepPlainObject) -> UIViewController {
        return module(lesson: lesson, step: step, stepPresenterDelegate: nil)
    }
}
