//
//  ActiveSplitTestsListProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol ActiveSplitTestsListProviderProtocol {
    func getActiveSplitTests() -> [String]
}

final class ActiveSplitTestsListProvider: ActiveSplitTestsListProviderProtocol {
    func getActiveSplitTests() -> [String] {
        return Array(ActiveSplitTestsContainer.activeSplitTestsInfo.keys)
    }
}
