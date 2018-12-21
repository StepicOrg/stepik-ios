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

    struct SyllabusData {
        let sections: [(UniqueIdentifierType, Section)]
        let units: [(UniqueIdentifierType, Unit?)]
    }

    // MARK: Use cases

    /// Course syllabus
    enum ShowSyllabus {
        struct Request { }

        struct Response {
            var result: Result<SyllabusData>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Load syllabus section
    enum ShowSyllabusSection {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CourseInfoTabSyllabusSectionViewModel])
    }
}
