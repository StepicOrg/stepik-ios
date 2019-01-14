//
//  CourseInfoCourseInfoDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum CourseInfo {
    enum Tab {
        case info
        case syllabus

        var title: String {
            switch self {
            case .info:
                return NSLocalizedString("CourseInfoTabInfo", comment: "")
            case .syllabus:
                return NSLocalizedString("CourseInfoTabSyllabus", comment: "")
            }
        }
    }

    // MARK: Use cases

    /// Load & show info about course
    enum ShowCourse {
        struct Response {
            var result: Result<Course>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Register submodules
    enum RegisterSubmodule {
        struct Request {
            var submodules: [CourseInfoSubmoduleProtocol]
        }
    }

    /// Show lesson
    enum ShowLesson {
        struct Response {
            let lesson: Lesson
            let unitID: Unit.IdType
            let navigationRules: LessonNavigationRules
            let navigationDelegate: SectionNavigationDelegate
        }

        @available(*, deprecated, message: "Old ugly Lesson controller initialization")
        struct ViewModel {
            let initObjects: LessonInitObjects
            let initIDs: LessonInitIds
            let navigationRules: LessonNavigationRules
            let navigationDelegate: SectionNavigationDelegate
        }
    }

    /// Show personal deadlines create / edit & delete action
    enum PersonalDeadlinesSettings {
        enum Action {
            case create
            case edit
        }

        struct Response {
            let action: Action

            @available(*, deprecated, message: "Should containts only course ID")
            let course: Course
        }

        struct ViewModel {
            let action: Action

            @available(*, deprecated, message: "Should containts only course ID")
            let course: Course
        }
    }

    /// Present exam in web
    enum ShowExamLesson {
        struct Response {
            let urlPath: String
        }

        struct ViewModel {
            let urlPath: String
        }
    }

    /// Share course
    enum ShareCourse {
        struct Response {
            let urlPath: String
        }

        struct ViewModel {
            let urlPath: String
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

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoHeaderViewModel)
    }
}
