//
//  AdaptiveStepsAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AdaptiveStepsAssembly: BaseAssembly, AdaptiveStepsAssemblyProtocol {
    func module(courseId: Int) -> UIViewController {
        return makeModule(courseId: courseId)
    }

    private func makeModule(courseId: Int) -> UIViewController {
        let controller = AdaptiveStepsViewController()
        let stepAssembly = StepAssemblyImpl(
            assemblyFactory: assemblyFactory,
            serviceFactory: serviceFactory
        )
        let presenter = AdaptiveStepsPresenter(
            view: controller,
            courseId: courseId,
            stepAssembly: stepAssembly,
            recommendationsService: serviceFactory.recommendationsService,
            reactionService: serviceFactory.reactionService,
            stepsService: serviceFactory.stepsService,
            courseService: serviceFactory.courseService,
            viewsService: serviceFactory.viewsService
        )
        controller.presenter = presenter
        controller.hidesBottomBarWhenPushed = true

        return controller
    }
}
