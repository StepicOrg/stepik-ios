//
//  CourseInfoCourseInfoAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class CourseInfoAssembly: Assembly {
    private let courseID: Course.IdType
    private let initialTab: CourseInfo.Tab

    init(courseID: Course.IdType, initialTab: CourseInfo.Tab = .info) {
        self.courseID = courseID
        self.initialTab = initialTab
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
            userAccountService: UserAccountService(),
            adaptiveStorageManager: AdaptiveStorageManager()
        )

        let viewController = CourseInfoViewController(
            interactor: interactor,
            availableTabs: self.getAvailableTabs(),
            initialTab: self.initialTab
        )
        presenter.viewController = viewController

        return viewController
    }

    private func getAvailableTabs() -> [CourseInfo.Tab] {
        let adaptiveManager = AdaptiveStorageManager()
        return adaptiveManager.canOpenInAdaptiveMode(courseId: self.courseID)
            ? [.info]
            : [.info, .syllabus]
    }
}
