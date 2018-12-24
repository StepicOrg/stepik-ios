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

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoHeaderViewModel)
    }
}
