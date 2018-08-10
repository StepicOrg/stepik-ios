//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepAssemblyImpl: BaseAssembly, StepAssembly {
    func module(lesson: LessonPlainObject, step: StepPlainObject, stepPresenterDelegate: StepPresenterDelegate?) -> UIViewController {
        let controller = StepViewController()
        let presenter = StepPresenterImpl(
            view: controller,
            delegate: stepPresenterDelegate,
            step: step,
            lesson: lesson,
            stepsService: serviceFactory.stepsService
        )
        controller.presenter = presenter

        return controller
    }
}
