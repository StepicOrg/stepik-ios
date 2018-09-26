//
//  ContinueCourseContinueCourseDataFlow.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum ContinueCourse {
    // MARK: Use cases

    /// Sample use case
    enum LoadLastCourse {
        struct Request { }

        struct Response {
            let result: Course
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: ContinueCourseViewModel)
    }
}
