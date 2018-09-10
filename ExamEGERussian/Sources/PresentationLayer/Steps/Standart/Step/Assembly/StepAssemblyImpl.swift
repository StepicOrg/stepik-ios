//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepAssemblyImpl: BaseAssembly, StepAssembly {
    func module(seed: StepModuleSeed) -> StepViewController {
        let controller = StepViewController()
        let router = StepRouter(viewController: controller, authAssembly: assemblyFactory.authAssembly)

        let builder = seed.quizViewControllerBuilder
        let presenter = StepPresenterImpl(
            view: controller,
            step: seed.step,
            lesson: seed.lesson,
            router: router,
            quizViewControllerBuilder: builder,
            delegate: seed.stepPresenterDelegate,
            stepsService: serviceFactory.stepsService
        )
        controller.presenter = presenter

        if builder.logoutable == nil {
            _ = builder.setLogoutable(presenter)
        }
        if builder.stepType == nil {
            _ = builder.setStepType(seed.step.type)
        }

        return controller
    }
}
