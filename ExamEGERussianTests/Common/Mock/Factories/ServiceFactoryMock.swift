//
//  ServiceFactoryMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class ServiceFactoryMock: ServiceFactory {
    let authAPI: AuthAPI

    let stepicsAPI: StepicsAPI

    let profilesAPI: ProfilesAPI

    let coursesAPI: CoursesAPI

    let enrollmentsAPI: EnrollmentsAPI

    let lessonsAPI: LessonsAPI

    let progressesAPI: ProgressesAPI

    var recommendationsAPI: RecommendationsAPI

    var unitsAPI: UnitsAPI

    var viewsAPI: ViewsAPI

    let defaultsStorageManager: DefaultsStorageManager

    let userRegistrationService: UserRegistrationService

    let graphService: GraphServiceProtocol

    let lessonsService: LessonsService

    let courseService: CourseService

    let enrollmentService: EnrollmentService

    let stepsService: StepsService

    let progressService: ProgressService

    var recommendationsService: RecommendationsServiceProtocol

    var reactionService: ReactionServiceProtocol

    var knowledgeGraphProvider: KnowledgeGraphProviderProtocol

    init() {
        self.authAPI = AuthAPI()
        self.stepicsAPI = StepicsAPI()
        self.profilesAPI = ProfilesAPI()
        self.coursesAPI = CoursesAPI()
        self.enrollmentsAPI = EnrollmentsAPI()
        self.lessonsAPI = LessonsAPI()
        self.progressesAPI = ProgressesAPI()
        self.recommendationsAPI = RecommendationsAPI()
        self.unitsAPI = UnitsAPI()
        self.viewsAPI = ViewsAPI()
        self.defaultsStorageManager = DefaultsStorageManager.shared
        self.userRegistrationService = UserRegistrationServiceMock()
        self.graphService = GraphServiceMock()
        self.lessonsService = LessonsServiceMock()
        self.courseService = CourseServiceMock()
        self.enrollmentService = EnrollmentServiceMock()
        self.stepsService = StepsServiceMock()
        self.progressService = ProgressServiceMock()
        self.recommendationsService = RecommendationsServiceMock()
        self.reactionService = ReactionServiceMock()
        self.knowledgeGraphProvider = KnowledgeGraphProviderMock()
    }
}
