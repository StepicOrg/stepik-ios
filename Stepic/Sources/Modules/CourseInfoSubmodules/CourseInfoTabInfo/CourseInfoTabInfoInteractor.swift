//
//  CourseInfoTabInfoInteractor.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabInfoInteractorProtocol {
    func doCourseInfoRefresh(request: CourseInfoTabInfo.InfoLoad.Request)
}

final class CourseInfoTabInfoInteractor: CourseInfoTabInfoInteractorProtocol {
    private let presenter: CourseInfoTabInfoPresenterProtocol
    private let provider: CourseInfoTabInfoProviderProtocol

    private var course: Course?

    private var shouldOpenedAnalyticsEventSend = false

    init(
        presenter: CourseInfoTabInfoPresenterProtocol,
        provider: CourseInfoTabInfoProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Get course info

    func doCourseInfoRefresh(request: CourseInfoTabInfo.InfoLoad.Request) {
        guard let course = self.course else {
            return
        }

        self.provider.fetchUsersForCourse(course).done { course in
            self.course = course
            self.presenter.presentCourseInfo(
                response: .init(course: self.course)
            )
        }.catch { error in
            print("Failed get course info with error: \(error)")
        }
    }
}

// MARK: - CourseInfoTabInfoInteractor: CourseInfoTabInfoInputProtocol -

extension CourseInfoTabInfoInteractor: CourseInfoTabInfoInputProtocol {
    func handleControllerAppearance() {
        if let course = self.course {
            AmplitudeAnalyticsEvents.CoursePreview.opened(
                courseID: course.id,
                courseTitle: course.title
            ).send()
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, isOnline: Bool) {
        self.course = course
        self.doCourseInfoRefresh(request: .init())

        if self.shouldOpenedAnalyticsEventSend {
            AmplitudeAnalyticsEvents.CoursePreview.opened(
                courseID: course.id,
                courseTitle: course.title
            ).send()
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}
