//
//  AssemblyFactoryMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class AssemblyFactoryMock: AssemblyFactory {
    let applicationAssembly: ApplicationAssembly = ApplicationAssemblyMock()

    var authAssembly: AuthAssembly = AuthAssemblyMock()

    var topicsAssembly: TopicsAssembly = TopicsAssemblyMock()

    var lessonsAssembly: LessonsAssembly = LessonsAssemblyMock()

    var stepsAssembly: StandartStepsAssemblyProtocol = StepsAssemblyMock()
}
