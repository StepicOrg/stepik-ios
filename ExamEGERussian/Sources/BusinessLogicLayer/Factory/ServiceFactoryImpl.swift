//
//  ServiceFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceFactoryImpl: ServiceFactory {

    // MARK: - ServiceFactory -

    let authAPI: AuthAPI
    let stepicsAPI: StepicsAPI
    let profilesAPI: ProfilesAPI
    let coursesAPI: CoursesAPI
    let enrollmentsAPI: EnrollmentsAPI
    let lessonsAPI: LessonsAPI
    let stepsAPI: StepsAPI
    let progressesAPI: ProgressesAPI

    let defaultsStorageManager: DefaultsStorageManager

    var userRegistrationService: UserRegistrationService {
        return UserRegistrationServiceImpl(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            profilesAPI: profilesAPI,
            defaultsStorageManager: defaultsStorageManager
        )
    }

    var graphService: GraphServiceProtocol {
        let fileStorage = FileStorage(destination: .atFolder(name: "knowledge-graph"))
        return GraphService(fileStorage: fileStorage)
    }

    var lessonsService: LessonsService {
        return LessonsServiceImpl(lessonsAPI: lessonsAPI)
    }

    var courseService: CourseService {
        return CourseServiceImpl(coursesAPI: coursesAPI, progressesService: self.progressService)
    }

    var enrollmentService: EnrollmentService {
        return EnrollmentServiceImpl(enrollmentsAPI: enrollmentsAPI)
    }

    var stepsService: StepsService {
        return StepsServiceImpl(stepsAPI: stepsAPI, progressService: self.progressService)
    }

    var progressService: ProgressService {
        return ProgressServiceImpl(progressesAPI: progressesAPI)
    }

    // MARK: - Init -

    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI,
         coursesAPI: CoursesAPI,
         enrollmentsAPI: EnrollmentsAPI,
         lessonsAPI: LessonsAPI,
         stepsAPI: StepsAPI,
         progressesAPI: ProgressesAPI,
         defaultsStorageManager: DefaultsStorageManager
    ) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
        self.coursesAPI = coursesAPI
        self.enrollmentsAPI = enrollmentsAPI
        self.lessonsAPI = lessonsAPI
        self.stepsAPI = stepsAPI
        self.progressesAPI = progressesAPI
        self.defaultsStorageManager = defaultsStorageManager
    }
}
