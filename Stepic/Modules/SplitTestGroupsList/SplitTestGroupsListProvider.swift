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

    func setGroup(
        _ groupUniqueIdentifier: UniqueIdentifierType,
        splitTestUniqueIdentifier: UniqueIdentifierType
    )
}

final class SplitTestGroupsListProvider: SplitTestGroupsListProviderProtocol {
    private let storage: StringStorageServiceProtocol

    init(storage: StringStorageServiceProtocol) {
        self.storage = storage
    }

    func getGroups(splitTestUniqueIdentifier: UniqueIdentifierType) -> [UniqueIdentifierType] {
        return self.getSplitTestInfo(splitTestUniqueIdentifier)?.groups ?? []
    }

    func getCurrentGroup(splitTestUniqueIdentifier: UniqueIdentifierType) -> UniqueIdentifierType? {
        if let splitTestInfo = self.getSplitTestInfo(splitTestUniqueIdentifier) {
            return self.storage.getString(for: splitTestInfo.databaseKey)
        } else {
            return nil
        }
    }

    func setGroup(
        _ groupUniqueIdentifier: UniqueIdentifierType,
        splitTestUniqueIdentifier: UniqueIdentifierType
    ) {
        if let splitTestInfo = self.getSplitTestInfo(splitTestUniqueIdentifier) {
            self.storage.save(string: groupUniqueIdentifier, for: splitTestInfo.databaseKey)
        }
    }

    private func getSplitTestInfo(
        _ splitTestUniqueIdentifier: UniqueIdentifierType
    ) -> ActiveSplitTestsContainer.SplitTestInfo? {
        return ActiveSplitTestsContainer.activeSplitTestsInfo[splitTestUniqueIdentifier]
    }
}
