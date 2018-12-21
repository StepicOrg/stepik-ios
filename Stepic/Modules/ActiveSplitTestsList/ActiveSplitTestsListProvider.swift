//
//  ActiveSplitTestsListProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol ActiveSplitTestsListProviderProtocol {
    func getActiveSplitTests() -> [UniqueIdentifierType]
}

final class ActiveSplitTestsListProvider: ActiveSplitTestsListProviderProtocol {
    func getActiveSplitTests() -> [UniqueIdentifierType] {
        return Array(ActiveSplitTestsContainer.activeSplitTestsInfo.keys)
    }
}
