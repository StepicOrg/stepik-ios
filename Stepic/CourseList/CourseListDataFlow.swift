//
//  CourseListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

enum CourseList {

    // MARK: Use cases

    enum ShowCourses {
        struct Request {
            var shouldAppend: Bool = false
        }

        struct Response {
            struct Data {
                var courses: [Course]
                var hasNextPage: Bool
                var shouldAppend: Bool = false
            }

            var result: Result<Data>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(courses: [CourseWidgetViewModel])
        case emptyResult
        case error(message: String)
    }

    struct State {
        typealias PaginationState = (page: Int, hasNext: Bool)

        var isOnline: Bool = false
        var paginationState: PaginationState = PaginationState(page: 1, hasNext: true)
    }
}

struct CourseWidgetViewModel { }
