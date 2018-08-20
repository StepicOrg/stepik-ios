//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepAssemblyImpl: BaseAssembly, StepAssembly {
    func module(lesson: LessonPlainObject, step: StepPlainObject, needNewAttempt: Bool, stepPresenterDelegate: StepPresenterDelegate?) -> UIViewController {
        let controller = StepViewController()
        let router = StepRouter(viewController: controller, authAssembly: assemblyFactory.authAssembly)
        let presenter = StepPresenterImpl(
            view: controller,
            step: step,
            lesson: lesson,
            needNewAttempt: needNewAttempt,
            router: router,
            delegate: stepPresenterDelegate,
            stepsService: serviceFactory.stepsService
        )
        controller.presenter = presenter

        return controller
    }
}
