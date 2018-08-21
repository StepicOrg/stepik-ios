//
//  ServiceFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceFactoryImpl: ServiceFactory {
    private static let knowledgeGraphDirectoryName = "knowledge-graph"

    let authAPI: AuthAPI
    let stepicsAPI: StepicsAPI
    let profilesAPI: ProfilesAPI
    let coursesAPI: CoursesAPI
    let enrollmentsAPI: EnrollmentsAPI
    let lessonsAPI: LessonsAPI
    let stepsAPI: StepsAPI
    let progressesAPI: ProgressesAPI
    let recommendationsAPI: RecommendationsAPI
    let unitsAPI: UnitsAPI
    let viewsAPI: ViewsAPI

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
        let fileStorage = FileStorage(destination: .atFolder(name: ServiceFactoryImpl.knowledgeGraphDirectoryName))
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

    var recommendationsService: RecommendationsServiceProtocol {
        return RecommendationsService(recommendationsAPI: recommendationsAPI, lessonsService: lessonsService)
    }

    var reactionService: ReactionServiceProtocol {
        return ReactionService(recommendationsAPI: recommendationsAPI)
    }

    var knowledgeGraphProvider: KnowledgeGraphProviderProtocol {
        return CachedKnowledgeGraphProvider(graphService: graphService)
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
         recommendationsAPI: RecommendationsAPI,
         unitsAPI: UnitsAPI,
         viewsAPI: ViewsAPI,
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
        self.recommendationsAPI = recommendationsAPI
        self.unitsAPI = unitsAPI
        self.viewsAPI = viewsAPI
        self.defaultsStorageManager = defaultsStorageManager
    }
}
