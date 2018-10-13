//
//  FullscreenCourseListFullscreenCourseListDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum FullscreenCourseList {

    // MARK: Use cases

    /// Present course syllabus
    enum PresentCourseSyllabus {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let course: Course
        }
    }
    /// Present course info
    enum PresentCourseInfo {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let course: Course
        }
    }
    /// Present last step in course
    enum PresentLastStep {
        struct Response {
            let course: Course
            let isAdaptive: Bool
        }

        struct ViewModel {
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let course: Course
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let isAdaptive: Bool
        }
    }
    /// Try to set online status
    enum TryToSetOnline {
        struct Request {
            let module: CourseListInputProtocol
        }
    }
}
