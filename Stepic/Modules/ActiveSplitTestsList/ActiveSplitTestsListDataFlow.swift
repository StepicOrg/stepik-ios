//
//  ActiveSplitTestsListDataFlow.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum ActiveSplitTestsList {
    // MARK: Use cases

    /// Show split tests list
    enum ShowSplitTests {
        struct Request {
        }

        struct Response {
            let splitTests: [UniqueIdentifierType]
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case emptyResult
        case result(data: [SplitTestViewModel])
    }
}
