//
//  CourseListsCollectionDataFlow.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum CourseListsCollection {
    // MARK: Use cases

    /// Show course lists
    enum ShowCourseLists {
        struct Request { }

        struct Response {
            var result: Result<[CourseListModel]>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }
    /// Present collection in fullscreen
    enum PresentFullscreenCourseListModule {
        struct Request {
            let presentationDescription: CourseList.PresentationDescription
            let courseListType: CourseListType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CourseListsCollectionViewModel])
    }
}
