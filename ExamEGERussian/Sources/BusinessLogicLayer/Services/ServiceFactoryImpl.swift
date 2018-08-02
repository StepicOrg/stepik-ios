//
//  ServiceFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceFactoryImpl: ServiceFactory {
    let authAPI: AuthAPI
    let stepicsAPI: StepicsAPI
    let profilesAPI: ProfilesAPI
    let coursesAPI: CoursesAPI
    let enrollmentsAPI: EnrollmentsAPI
    let lessonsAPI: LessonsAPI
    let stepsAPI: StepsAPI

    let defaultsStorageManager: DefaultsStorageManager

    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI,
         coursesAPI: CoursesAPI,
         enrollmentsAPI: EnrollmentsAPI,
         lessonsAPI: LessonsAPI,
         stepsAPI: StepsAPI,
         defaultsStorageManager: DefaultsStorageManager
        ) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
        self.coursesAPI = coursesAPI
        self.enrollmentsAPI = enrollmentsAPI
        self.lessonsAPI = lessonsAPI
        self.stepsAPI = stepsAPI
        self.defaultsStorageManager = defaultsStorageManager
    }

    var userRegistrationService: UserRegistrationService {
        return UserRegistrationServiceImpl(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            profilesAPI: profilesAPI,
            defaultsStorageManager: defaultsStorageManager
        )
    }

    var graphService: GraphService {
        return GraphServiceImpl()
    }

    var lessonsService: LessonsService {
        return LessonsServiceImpl(lessonsAPI: lessonsAPI)
    }

    var courseService: CourseService {
        return CourseServiceImpl(coursesAPI: coursesAPI)
    }

    var enrollmentService: EnrollmentService {
        return EnrollmentServiceImpl(enrollmentsAPI: enrollmentsAPI)
    }

    var stepsService: StepsService {
        return StepsServiceImpl(stepsAPI: stepsAPI)
    }
}
