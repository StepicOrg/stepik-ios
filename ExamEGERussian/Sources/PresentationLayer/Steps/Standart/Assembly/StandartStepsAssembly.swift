//
//  StandartStepsAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 02/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UINavigationController

final class StandartStepsAssembly: BaseAssembly, StandartStepsAssemblyProtocol {
    func module(navigationController: UINavigationController, lesson: LessonPlainObject) -> UIViewController {
        let stepAssemby = StepAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
        let dataSource = StepsPagerDataSourceImpl(lesson: lesson, assembly: stepAssemby)
        let controller = StepsPagerViewController(strongDataSource: dataSource)
        controller.title = lesson.title

        let router = StepsPagerRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = StepsPagerPresenterImpl(
            view: controller,
            lesson: lesson,
            router: router,
            stepsService: serviceFactory.stepsService
        )
        controller.presenter = presenter
        controller.hidesBottomBarWhenPushed = true
        dataSource.stepPresenterDelegate = presenter

        return controller
    }
}
