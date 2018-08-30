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
}

final class CourseListInteractor: CourseListInteractorProtocol {
    let presenter: CourseListPresenterProtocol
    let provider: CourseListProviderProtocol

    private var state: CourseList.State

    init(
        state: CourseList.State = CourseList.State(),
        presenter: CourseListPresenterProtocol,
        provider: CourseListProviderProtocol
    ) {
        self.state = state
        self.presenter = presenter
        self.provider = provider
    }

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

            let result = Result.success(
                CourseList.ListData(courses: courses, hasNextPage: meta.hasNext)
            )
            let response = CourseList.ShowCourses.Response(result: result)
            self.presenter.presentCourses(response: response)
        }.catch { _ in
            let result = Result<CourseList.ListData<Course>>.failure(Error.fetchFailed)
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
                CourseList.ListData<Course>(courses: [], hasNextPage: false)
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

            let result = Result.success(
                CourseList.ListData(courses: courses, hasNextPage: meta.hasNext)
            )
            let response = CourseList.LoadNextCourses.Response(result: result)
            self.presenter.presentNextCourses(response: response)
        }.catch { _ in
            let result = Result<CourseList.ListData<Course>>.failure(Error.fetchFailed)
            let response = CourseList.LoadNextCourses.Response(result: result)
            self.presenter.presentNextCourses(response: response)
        }
    }

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
