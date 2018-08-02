//
//  StepsAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 02/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepsAssemblyImpl: BaseAssembly, StepsAssembly {
    func module(navigationController: UINavigationController, lesson: LessonPlainObject) -> UIViewController {
        return StepsViewController(
            lesson: lesson,
            stepsService: serviceFactory.stepsService
        )
    }
}
