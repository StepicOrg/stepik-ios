//
//  UseCaseFactory.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class UseCaseFactory: UseCaseFactoryProtocol {
    private let serviceFactory: ServiceFactory

    var joinCourseUseCase: JoinCourseUseCaseProtocol {
        return JoinCourseUseCase(
            courseService: serviceFactory.courseService,
            enrollmentService: serviceFactory.enrollmentService
        )
    }

    init(serviceFactory: ServiceFactory) {
        self.serviceFactory = serviceFactory
    }
}
