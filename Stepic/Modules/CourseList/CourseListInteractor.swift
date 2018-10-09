//
//  CourseListInteractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseListInteractorProtocol: class {
    func fetchCourses(request: CourseList.ShowCourses.Request)
    func fetchNextCourses(request: CourseList.LoadNextCourses.Request)

    func doPrimaryAction(request: CourseList.PrimaryCourseAction.Request)
    func doSecondaryAction(request: CourseList.SecondaryCourseAction.Request)
    func doMainAction(request: CourseList.MainCourseAction.Request)
}

final class CourseListInteractor: CourseListInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    // We should be able to set uid cause we want to manage
    // which course list module called module output methods
    var moduleIdentifier: UniqueIdentifierType?

    weak var moduleOutput: CourseListOutputProtocol?

    let presenter: CourseListPresenterProtocol
    let provider: CourseListProviderProtocol
    let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    let courseSubscriber: CourseSubscriberProtocol
    let userAccountService: UserAccountServiceProtocol

    private var isOnline: Bool = false
    private var paginationState = PaginationState(page: 1, hasNext: true)
    private var currentCourses: [(UniqueIdentifierType, Course)] = []

    init(
        presenter: CourseListPresenterProtocol,
        provider: CourseListProviderProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        courseSubscriber: CourseSubscriberProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.adaptiveStorageManager = adaptiveStorageManager
        self.courseSubscriber = courseSubscriber
        self.userAccountService = userAccountService

        self.registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public methods

    func fetchCourses(request: CourseList.ShowCourses.Request) {
        // Check for state and if state == offline, just fetch cached courses
        // if state == online, fetch from network and show
        firstly {
            self.isOnline
                ? self.provider.fetchRemote(page: 1)
                : self.provider.fetchCached()
        }.done { courses, meta in
            self.paginationState = PaginationState(
                page: meta.page,
                hasNext: meta.hasNext
            )

            self.currentCourses = courses.map { (self.getUniqueIdentifierForCourse($0), $0) }
            if self.currentCourses.isEmpty {
                self.moduleOutput?.presentEmptyState(sourceModule: self)
            } else {
                let courses = CourseList.AvailableCourses(
                    fetchedCourses: CourseList.ListData(
                        courses: self.currentCourses,
                        hasNextPage: meta.hasNext
                    ),
                    availableAdaptiveCourses: self.getAvailableAdaptiveCourses(from: courses)
                )
                let response = CourseList.ShowCourses.Response(
                    isAuthorized: self.userAccountService.isAuthorized,
                    result: courses
                )
                self.presenter.presentCourses(response: response)
            }
        }.catch { _ in
            self.moduleOutput?.presentError(sourceModule: self)
        }
    }

    func fetchNextCourses(request: CourseList.LoadNextCourses.Request) {
        // If we are
        // - in offline mode
        // - have no more courses
        // then ignore request and pass empty list to presenter
        if !self.isOnline || !self.paginationState.hasNext {
            let result = CourseList.AvailableCourses(
                fetchedCourses: CourseList.ListData(courses: [], hasNextPage: false),
                availableAdaptiveCourses: Set<Course>()
            )
            let response = CourseList.LoadNextCourses.Response(
                isAuthorized: self.userAccountService.isAuthorized,
                result: result
            )
            self.presenter.presentNextCourses(response: response)
            return
        }

        let nextPageNumber = self.paginationState.page + 1
        self.provider.fetchRemote(page: nextPageNumber).done { courses, meta in
            self.paginationState = PaginationState(
                page: meta.page,
                hasNext: meta.hasNext
            )

            let appendedCourses = courses.map { (self.getUniqueIdentifierForCourse($0), $0) }
            self.currentCourses.append(contentsOf: appendedCourses)
            let courses = CourseList.AvailableCourses(
                fetchedCourses: CourseList.ListData(
                    courses: appendedCourses,
                    hasNextPage: meta.hasNext
                ),
                availableAdaptiveCourses: self.getAvailableAdaptiveCourses(from: courses)
            )
            let response = CourseList.LoadNextCourses.Response(
                isAuthorized: self.userAccountService.isAuthorized,
                result: courses
            )
            self.presenter.presentNextCourses(response: response)
        }.catch { _ in

        }
    }

    func doPrimaryAction(request: CourseList.PrimaryCourseAction.Request) {
        self.presenter.presentWaitingState()

        guard let targetIndex = self.currentCourses.index(where: { $0.0 == request.viewModelUniqueIdentifier }),
              let targetCourse = self.currentCourses[safe: targetIndex]?.1 else {
            fatalError("Invalid module state")
        }

        if !self.userAccountService.isAuthorized {
            self.presenter.dismissWaitingState()
            self.moduleOutput?.presentAuthorization()
            return
        }

        if targetCourse.enrolled {
            // Enrolled course -> open last step
            self.moduleOutput?.presentLastStep(
                course: targetCourse,
                isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                    courseId: targetCourse.id
                )
            )
            self.presenter.dismissWaitingState()
        } else {
            // Unenrolled course -> join, open last step
            self.courseSubscriber.join(course: targetCourse, source: .widget).done { course in
                self.currentCourses[targetIndex].1 = course
                self.moduleOutput?.presentLastStep(
                    course: targetCourse,
                    isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                        courseId: targetCourse.id
                    )
                )
                self.presenter.dismissWaitingState()
            }.catch { _ in

            }
        }
    }

    func doSecondaryAction(request: CourseList.SecondaryCourseAction.Request) {
        self.presenter.presentWaitingState()

        guard let targetIndex = self.currentCourses.index(where: { $0.0 == request.viewModelUniqueIdentifier }),
              let targetCourse = self.currentCourses[safe: targetIndex]?.1 else {
            fatalError("Invalid module state")
        }

        defer {
            self.presenter.dismissWaitingState()
        }

        if targetCourse.enrolled {
            // Enrolled course
            // - adaptive -> info
            // - normal -> syllabus
            if self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: targetCourse.id) {
                self.moduleOutput?.presentCourseInfo(course: targetCourse)
            } else {
                self.moduleOutput?.presentCourseSyllabus(course: targetCourse)
            }
        } else {
            // Unenrolled course
            // - adaptive -> info
            // - normal -> info
            self.moduleOutput?.presentCourseInfo(course: targetCourse)
        }
    }

    func doMainAction(request: CourseList.MainCourseAction.Request) {
        self.presenter.presentWaitingState()

        guard let targetIndex = self.currentCourses.index(where: { $0.0 == request.viewModelUniqueIdentifier }),
              let targetCourse = self.currentCourses[safe: targetIndex]?.1 else {
            fatalError("Invalid module state")
        }

        defer {
            self.presenter.dismissWaitingState()
        }

        if targetCourse.enrolled && self.userAccountService.isAuthorized {
            // Enrolled course -> open last step
            self.moduleOutput?.presentLastStep(
                course: targetCourse,
                isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                    courseId: targetCourse.id
                )
            )
        } else {
            // Unenrolled course -> info
            self.moduleOutput?.presentCourseInfo(course: targetCourse)
        }
    }

    // MARK: - Private methods

    private func getAvailableAdaptiveCourses(from courses: [Course]) -> Set<Course> {
        let availableInAdaptiveMode = courses
            .filter { self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: $0.id) }
        return Set<Course>(availableInAdaptiveMode)
    }

    private func getUniqueIdentifierForCourse(_ course: Course) -> UniqueIdentifierType {
        return "\(course.id)"
    }

    // MARK: - Notifications

    private func registerForNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: .courseSubscribedNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .courseUnsubscribedNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleCourseSubscription(_:)),
            name: .courseSubscribedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleCourseUnsubscription(_:)),
            name: .courseUnsubscribedNotification,
            object: nil
        )
    }

    @objc
    private func handleCourseSubscription(_ notification: Foundation.Notification) {
        if let course = notification.userInfo?["course"] as? Course {
            self.updateCourseInCurrentCourses(course)
            self.refreshCourseList()
        }
    }

    @objc
    private func handleCourseUnsubscription(_ notification: Foundation.Notification) {
        if let course = notification.userInfo?["course"] as? Course {
            self.updateCourseInCurrentCourses(course)
            self.refreshCourseList()
        }
    }

    private func updateCourseInCurrentCourses(_ course: Course) {
        guard let targetIndex = self.currentCourses.index(where: { $0.1 == course }) else {
            return
        }
        self.currentCourses[targetIndex] = (self.getUniqueIdentifierForCourse(course), course)
    }

    /// Just present current data again
    private func refreshCourseList() {
        let courses = CourseList.AvailableCourses(
            fetchedCourses: CourseList.ListData(
                courses: self.currentCourses,
                hasNextPage: self.paginationState.hasNext
            ),
            availableAdaptiveCourses: self.getAvailableAdaptiveCourses(
                from: self.currentCourses.map { $0.1 }
            )
        )
        let response = CourseList.ShowCourses.Response(
            isAuthorized: self.userAccountService.isAuthorized,
            result: courses
        )
        self.presenter.presentCourses(response: response)
    }

    // MARK: - Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListInteractor: CourseListInputProtocol {
    func setOnlineStatus() {
        self.isOnline = true

        let fakeRequest = CourseList.ShowCourses.Request()
        self.fetchCourses(request: fakeRequest)
    }

    func setOfflineStatus() {
        self.isOnline = false

        let fakeRequest = CourseList.ShowCourses.Request()
        self.fetchCourses(request: fakeRequest)
    }
}
