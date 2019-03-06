//
//  BaseExploreBaseExploreDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 02/10/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum BaseExplore {
    // MARK: Use cases

    /// Present fullscreen module
    enum PresentFullscreenCourseListModule {
        struct Request {
            let presentationDescription: CourseList.PresentationDescription?
            let courseListType: CourseListType
        }

        struct Response {
            let presentationDescription: CourseList.PresentationDescription?
            let courseListType: CourseListType
        }

        struct ViewModel {
            let presentationDescription: CourseList.PresentationDescription?
            let courseListType: CourseListType
        }
    }

    /// Present course syllabus
    enum PresentCourseSyllabus {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    /// Present course info
    enum PresentCourseInfo {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let courseID: Course.IdType
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

    enum PresentAuthorization {
        struct Response { }

        struct ViewModel { }
    }

    /// Try to set online status for submodules
    enum TryToSetOnline {
        struct Request {
            let modules: [CourseListInputProtocol]
        }
    }
}
