//
//  SplitTestGroupsListSplitTestGroupsListProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol SplitTestGroupsListProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]>
}

final class SplitTestGroupsListProvider: SplitTestGroupsListProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]> {
        return Promise<[Any]> { seal in
            seal.fulfill(["" as! Any])
        }
    }
}
