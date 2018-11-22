//
//  CourseInfoTabInfoDataFlow.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum CourseInfoTabInfo {
    // MARK: Use cases

    enum ShowInfo {
        struct Request {
        }

        struct Response {
            let course: Course?
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Click on action button
    enum CourseAction {
        struct Request {
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoTabInfoViewModel)
    }
}
