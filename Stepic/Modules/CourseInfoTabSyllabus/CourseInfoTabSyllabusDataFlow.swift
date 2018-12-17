//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import Foundation

enum CourseInfoTabSyllabus {
    // MARK: Common structs
    // Place here structs used in Requests/Responses

    // MARK: Use cases

    /// Course syllabus
    enum ShowSyllabus {
        struct Request { }

        struct Response {
            var result: Result<Course>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CourseInfoTabSyllabusSectionViewModel])
    }
}
