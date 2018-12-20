//
//  SplitTestGroupsListSplitTestGroupsListDataFlow.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum SplitTestGroupsList {
    // MARK: Use cases

    /// Show split test groups list
    enum ShowGroups {
        struct Request {
        }

        struct Response {
            let groups: [String]
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case result(data: [SplitTestGroupViewModel])
        case emptyResult
    }
}
