//
//  SplitTestGroupsListSplitTestGroupsListProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol SplitTestGroupsListProviderProtocol {
    func getSplitTestGroups(id: UniqueIdentifierType) -> [String]
}

final class SplitTestGroupsListProvider: SplitTestGroupsListProviderProtocol {
    func getSplitTestGroups(id: UniqueIdentifierType) -> [String] {
        return []
    }
}
