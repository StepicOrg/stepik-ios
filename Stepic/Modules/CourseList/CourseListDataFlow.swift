//
//  CourseListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

enum CourseList {
    // MARK: Common structs

    struct ListData<T> {
        var courses: [T]
        var hasNextPage: Bool
    }

    // We should pass not only courses
    // but also info about which of them can be opened in adaptive mode
    struct AvailableCourses {
        var fetchedCourses: ListData<Course>
        var availableAdaptiveCourses: Set<Course>
    }

    // MARK: Use cases

    /// Load and show courses for given course list
    enum ShowCourses {
        struct Request { }

        struct Response {
            var result: Result<AvailableCourses>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }
    /// Load and show next course page for given course list
    enum LoadNextCourses {
        struct Request { }

        struct Response {
            var result: Result<AvailableCourses>
        }

        struct ViewModel {
            var state: PaginationState
        }
    }
    /// Course join
    enum JoinCourse {
        struct Request {
            var id: Course.IdType
        }

        struct Response { }

        struct ViewModel { }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: ListData<CourseWidgetViewModel>)
        case emptyResult
        case error(message: String)
    }

    enum PaginationState {
        case result(data: ListData<CourseWidgetViewModel>)
        case error(message: String)
    }

    struct State {
        typealias PaginationState = (page: Int, hasNext: Bool)

        var isOnline: Bool = false
        var paginationState = PaginationState(page: 1, hasNext: true)
        var courses: [Course] = []
    }
}
