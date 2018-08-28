//
//  StepsAssemblyMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class StepsAssemblyMock: StepsAssemblyProtocol {
    var standart: StandartStepsAssemblyProtocol = StandartStepsAssemblyMock()
    var adaptive: AdaptiveStepsAssemblyProtocol = AdaptiveStepsAssemblyMock()
}

final class StandartStepsAssemblyMock: StandartStepsAssemblyProtocol {
    func module(navigationController: UINavigationController, lesson: LessonPlainObject) -> UIViewController {
        return MockAssemblyViewController()
    }
}

final class AdaptiveStepsAssemblyMock: AdaptiveStepsAssemblyProtocol {
    var viewControllerToReturn: UIViewController?

    func module(topicId: String) -> UIViewController? {
        return viewControllerToReturn
    }
}
