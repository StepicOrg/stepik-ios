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
    enum FullscreenCourseListModulePresentation {
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
    enum CourseSyllabusPresentation {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    /// Present course info
    enum CourseInfoPresentation {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    /// Present last step in course
    enum LastStepPresentation {
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

    enum AuthorizationPresentation {
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
