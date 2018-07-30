//
//  ServiceComponentsAssemblyTestsHelper.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 05/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class ServiceFactoryTestsHelper {
    let serviceFactory: ServiceFactory

    init() {
        serviceFactory = ServiceFactoryImpl(
            authAPI: AuthAPI(),
            stepicsAPI: StepicsAPI(),
            profilesAPI: ProfilesAPI(),
            coursesAPI: CoursesAPI(),
            enrollmentsAPI: EnrollmentsAPI(),
            lessonsAPI: LessonsAPI(),
            defaultsStorageManager: DefaultsStorageManager.shared
        )
    }
}
