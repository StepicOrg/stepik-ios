//
//  SplitTestGroupsListSplitTestGroupsListProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol SplitTestGroupsListProviderProtocol {
    func getGroups(splitTestUniqueIdentifier: UniqueIdentifierType) -> [UniqueIdentifierType]
    func getCurrentGroup(splitTestUniqueIdentifier: UniqueIdentifierType) -> UniqueIdentifierType?
}

final class SplitTestGroupsListProvider: SplitTestGroupsListProviderProtocol {
    private let storage: StringStorageServiceProtocol

    init(storage: StringStorageServiceProtocol) {
        self.storage = storage
    }

    func getGroups(splitTestUniqueIdentifier: UniqueIdentifierType) -> [UniqueIdentifierType] {
        return ActiveSplitTestsContainer.activeSplitTestsInfo[splitTestUniqueIdentifier] ?? []
    }

    func getCurrentGroup(splitTestUniqueIdentifier: UniqueIdentifierType) -> UniqueIdentifierType? {
        return self.storage.getString(for: splitTestUniqueIdentifier)
    }
}
