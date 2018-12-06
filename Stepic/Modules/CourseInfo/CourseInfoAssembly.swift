//
//  CourseInfoCourseInfoAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class CourseInfoAssembly: Assembly {
    private var courseID: Course.IdType

    init(courseID: Course.IdType) {
        self.courseID = courseID
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoProvider(
            courseID: self.courseID,
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            reviewSummariesPersistenceService: CourseReviewSummariesPersistenceService(),
            reviewSummariesNetworkService: CourseReviewSummariesNetworkService(
                courseReviewSummariesAPI: CourseReviewSummariesAPI()
            )
        )
        let presenter = CourseInfoPresenter()
        let interactor = CourseInfoInteractor(
            courseID: self.courseID,
            presenter: presenter,
            provider: provider,
            networkReachabilityService: NetworkReachabilityService(),
            courseSubscriber: CourseSubscriber(),
            userAccountService: UserAccountService()
        )
        let viewController = CourseInfoViewController(
            interactor: interactor
        )
        presenter.viewController = viewController
        return viewController
    }
}
