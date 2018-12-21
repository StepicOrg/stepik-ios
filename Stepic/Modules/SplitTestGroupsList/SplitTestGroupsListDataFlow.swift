//
//  SplitTestGroupsListSplitTestGroupsListDataFlow.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum SplitTestGroupsList {
    // MARK: Common structs
    struct Group {
        let uniqueIdentifier: UniqueIdentifierType
        let isCurrent: Bool
    }

    // MARK: Use cases

    /// Show split test groups list
    enum ShowGroups {
        struct Request {
        }

        struct Response {
            let groups: [Group]
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Change split test group
    enum SelectGroup {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let groups: [Group]
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
