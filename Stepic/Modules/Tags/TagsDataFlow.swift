//
//  TagsTagsDataFlow.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum Tags {
    // MARK: Common structs
    struct Tag {
        // cause CourseTag sucks (we should have language in each layer)
        var id: Int
        var title: String
        var summary: String
    }

    // MARK: Use cases

    /// Show tag list
    enum ShowTags {
        struct Request { }

        struct Response {
            var result: Result<[Tag]>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [TagViewModel])
        case emptyResult
        case error(message: String)
    }
}
