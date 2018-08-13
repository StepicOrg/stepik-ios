//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepAssemblyImpl: StepAssembly {
    func module(lesson: LessonPlainObject, step: StepPlainObject) -> UIViewController {
        let controller = StepViewController()
        let presenter = StepPresenterImpl(
            view: controller,
            step: step,
            lesson: lesson
        )
        controller.presenter = presenter

        return controller
    }
}
