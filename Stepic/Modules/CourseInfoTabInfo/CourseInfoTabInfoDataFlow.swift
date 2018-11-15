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

    enum Something {
        struct Request {
        }

        struct Response {
            var result: Result<[Any]>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [Any])
        case emptyResult
        case error(message: String)
    }
}
