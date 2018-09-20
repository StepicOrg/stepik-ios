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

    func joinCourse(request: CourseList.JoinCourse.Request)
}

final class CourseListInteractor: CourseListInteractorProtocol {
    let presenter: CourseListPresenterProtocol
    let provider: CourseListProviderProtocol
    let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    let courseSubscriber: CourseSubscriberProtocol

    private var state: CourseList.State

    init(
        state: CourseList.State = CourseList.State(),
        presenter: CourseListPresenterProtocol,
        provider: CourseListProviderProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        courseSubscriber: CourseSubscriberProtocol
    ) {
        self.state = state
        self.presenter = presenter
        self.provider = provider
        self.adaptiveStorageManager = adaptiveStorageManager
        self.courseSubscriber = courseSubscriber
    }

    // MARK: - Public methods

    func fetchCourses(request: CourseList.ShowCourses.Request) {
        // Check for state and if state == offline, just fetch cached courses
        // if state == online, fetch from network and show
        firstly {
            self.state.isOnline
                ? self.provider.fetchRemote(page: 1)
                : self.provider.fetchCached()
        }.done { (courses, meta) in
            self.state.paginationState = CourseList.State.PaginationState(
                page: meta.page,
                hasNext: meta.hasNext
            )

            self.state.courses = courses
            let courses = CourseList.AvailableCourses(
                fetchedCourses: CourseList.ListData(courses: courses, hasNextPage: meta.hasNext),
                availableAdaptiveCourses: self.getAvailableAdaptiveCourses(from: courses)
            )
            let response = CourseList.ShowCourses.Response(result: Result.success(courses))
            self.presenter.presentCourses(response: response)
        }.catch { _ in
            let result = Result<CourseList.AvailableCourses>.failure(Error.fetchFailed)
            let response = CourseList.ShowCourses.Response(result: result)
            self.presenter.presentCourses(response: response)
        }
    }

    func fetchNextCourses(request: CourseList.LoadNextCourses.Request) {
        // If we are
        // - in offline mode
        // - have no more courses
        // then ignore request and pass empty list to presenter
        if !self.state.isOnline || !self.state.paginationState.hasNext {
            let result = Result.success(
                CourseList.AvailableCourses(
                    fetchedCourses: CourseList.ListData(courses: [], hasNextPage: false),
                    availableAdaptiveCourses: Set<Course>()
                )
            )
            let response = CourseList.LoadNextCourses.Response(result: result)
            self.presenter.presentNextCourses(response: response)
            return
        }

        let nextPageNumber = self.state.paginationState.page + 1
        self.provider.fetchRemote(page: nextPageNumber).done { (courses, meta) in
            self.state.paginationState = CourseList.State.PaginationState(
                page: meta.page,
                hasNext: meta.hasNext
            )

            self.state.courses.append(contentsOf: courses)
            let courses = CourseList.AvailableCourses(
                fetchedCourses: CourseList.ListData(courses: courses, hasNextPage: meta.hasNext),
                availableAdaptiveCourses: self.getAvailableAdaptiveCourses(from: courses)
            )
            let response = CourseList.LoadNextCourses.Response(result: Result.success(courses))
            self.presenter.presentNextCourses(response: response)
        }.catch { _ in
            let result = Result<CourseList.AvailableCourses>.failure(Error.fetchFailed)
            let response = CourseList.LoadNextCourses.Response(result: result)
            self.presenter.presentNextCourses(response: response)
        }
    }

    func joinCourse(request: CourseList.JoinCourse.Request) {
        guard let targetCourse = self.state.courses.filter({ $0.id == request.id }).first,
              let indexOfTargetCourse = self.state.courses.index(of: targetCourse) else {
            return self.presenter.presentJoinCourseReaction(response: .init())
        }

        self.courseSubscriber.join(course: targetCourse, source: .widget).done { course in
            self.state.courses[indexOfTargetCourse] = course
            self.presenter.presentJoinCourseReaction(response: .init())
        }.catch { _ in
            self.presenter.presentJoinCourseReaction(response: .init())
        }
    }

    // MARK: - Private methods

    private func getAvailableAdaptiveCourses(from courses: [Course]) -> Set<Course> {
        let availableInAdaptiveMode = courses
            .filter { self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: $0.id) }
        return Set<Course>(availableInAdaptiveMode)
    }

    // MARK: - Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListInteractor: CourseListInputProtocol {
    func reload() {
        self.state.isOnline = true

        let fakeRequest = CourseList.ShowCourses.Request()
        self.fetchCourses(request: fakeRequest)
    }
}
