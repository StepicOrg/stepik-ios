//
//  ExploreExploreDataFlow.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum Explore {
    // MARK: Common structs
    // Place here structs used in Requests/Responses

    // MARK: Use cases

    /// Sample use case
    enum Something {
        struct Request { }

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
