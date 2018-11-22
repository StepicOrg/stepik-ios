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
    func getCourseInfo(request: CourseInfoTabInfo.ShowInfo.Request)

    func doCourseAction(request: CourseInfoTabInfo.CourseAction.Request)
}

final class CourseInfoTabInfoInteractor: CourseInfoTabInfoInteractorProtocol, CourseInfoTabInfoInputProtocol {
    weak var moduleOutput: CourseInfoTabInfoOutputProtocol?

    let presenter: CourseInfoTabInfoPresenterProtocol
    let provider: CourseInfoTabInfoProviderProtocol

    let analytics: CourseInfoTabInfoAnalyticsProtocol
    let userAccountService: UserAccountServiceProtocol
    let courseSubscriber: CourseSubscriberProtocol
    let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    var course: Course? {
        didSet {
            self.getCourseInfo(request: .init())
        }
    }

    init(
        presenter: CourseInfoTabInfoPresenterProtocol,
        provider: CourseInfoTabInfoProviderProtocol,
        analytics: CourseInfoTabInfoAnalyticsProtocol,
        userAccountService: UserAccountServiceProtocol,
        courseSubscriber: CourseSubscriberProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
        self.userAccountService = userAccountService
        self.courseSubscriber = courseSubscriber
        self.adaptiveStorageManager = adaptiveStorageManager
    }

    // MARK: Get course info

    func getCourseInfo(request: CourseInfoTabInfo.ShowInfo.Request) {
        self.fetchInstructors().then {
            self.fetchAuthors()
        }.done {
            self.presenter.presentCourseInfo(
                response: .init(course: self.course)
            )
        }.catch { error in
            print("Failed get course info with error: \(error)")
        }
    }

    private func fetchInstructors() -> Promise<Void> {
        if let course = self.course {
            return self.provider.fetchInstructors(course: course).done { users in
                course.instructors = Sorter.sort(users, byIds: course.instructorsArray)
            }
        } else {
            return .value(())
        }
    }

    private func fetchAuthors() -> Promise<Void> {
        if let course = self.course {
            return self.provider.fetchAuthors(course: course).done { users in
                course.authors = Sorter.sort(users, byIds: course.authorsArray)
            }
        } else {
            return .value(())
        }
    }

    // MARK: Course action

    func doCourseAction(request: CourseInfoTabInfo.CourseAction.Request) {
        guard let course = self.course else {
            return self.presenter.presentErrorState()
        }

        self.presenter.presentWaitingState()

        if !self.userAccountService.isAuthorized {
            self.presenter.dismissWaitingState()
            self.moduleOutput?.presentAuthorization()
            return
        }

        if course.enrolled {
            self.openLastStep(course: course)
        } else {
            self.courseSubscriber.join(course: course, source: .courseInfoTab).done { course in
                self.analytics.reportContinuePressedForCourseWithId(course.id, title: course.title)
                self.openLastStep(course: course)
                self.course = course
            }.catch { error in
                print("CourseInfoTabInfo: failed join course with error: \(error)")
                self.presenter.presentErrorState()
            }
        }
    }

    private func openLastStep(course: Course) {
        self.presenter.dismissWaitingState()
        self.moduleOutput?.presentLastStep(
            course: course,
            isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                courseId: course.id
            )
        )
    }
}
