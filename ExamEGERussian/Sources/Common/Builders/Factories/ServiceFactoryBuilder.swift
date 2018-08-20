//
//  ServiceFactoryBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceFactoryBuilder {
    func build() -> ServiceFactory {
        return ServiceFactoryImpl(
            authAPI: AuthAPI(),
            stepicsAPI: StepicsAPI(),
            profilesAPI: ProfilesAPI(),
            coursesAPI: CoursesAPI(),
            enrollmentsAPI: EnrollmentsAPI(),
            lessonsAPI: LessonsAPI(),
            stepsAPI: StepsAPI(),
            progressesAPI: ProgressesAPI(),
            defaultsStorageManager: DefaultsStorageManager.shared
        )
    }
}
