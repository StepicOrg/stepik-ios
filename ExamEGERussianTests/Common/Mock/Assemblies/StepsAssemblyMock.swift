//
//  StepsAssemblyMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class StepsAssemblyMock: StepsAssembly {
    func module(navigationController: UINavigationController, lesson: LessonPlainObject) -> UIViewController {
        return MockAssemblyViewController()
    }
}
