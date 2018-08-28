//
//  CourseListInteractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

protocol CourseListInteractorProtocol: class {
    func fetchCourses(request: CourseList.ShowCourses.Request)
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
        self.provider.fetch(
            shouldFetchOnlyCached: !self.state.isOnline,
            page: self.state.paginationState.page
        ).done { (courses, meta) in
            self.state.paginationState = CourseList.State.PaginationState(
                page: meta.page,
                hasNext: meta.hasNext
            )

            let result = Result.success(
                CourseList.ShowCourses.Response.Data(
                    courses: courses,
                    hasNextPage: meta.hasNext,
                    shouldAppend: request.shouldAppend
                )
            )
            let response = CourseList.ShowCourses.Response(result: result)
            self.presenter.presentCourses(response: response)
        }.catch { _ in
            let result = Result<CourseList.ShowCourses.Response.Data>
                .failure(Error.fetchFailed)
            let response = CourseList.ShowCourses.Response(result: result)
            self.presenter.presentCourses(response: response)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListInteractor: CourseListInputProtocol {
    func reload() {
        self.state.isOnline = true

        let fakeRequest = CourseList.ShowCourses.Request(shouldAppend: false)
        self.fetchCourses(request: fakeRequest)
    }
}
