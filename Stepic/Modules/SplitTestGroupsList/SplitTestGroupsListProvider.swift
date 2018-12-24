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
    private let activeSplitTestInfoProvider: ActiveSplitTestInfoProvider
    private let storage: StringStorageServiceProtocol

    init(
        splitTestInfoProvider: ActiveSplitTestInfoProvider,
        storage: StringStorageServiceProtocol
    ) {
        self.activeSplitTestInfoProvider = splitTestInfoProvider
        self.storage = storage
    }

    func getGroups(splitTestUniqueIdentifier: UniqueIdentifierType) -> [UniqueIdentifierType] {
        return self.activeSplitTestInfoProvider.getSplitTestInfo(for: splitTestUniqueIdentifier)?.groups ?? []
    }

    func getCurrentGroup(splitTestUniqueIdentifier: UniqueIdentifierType) -> UniqueIdentifierType? {
        if let splitTestInfo = self.activeSplitTestInfoProvider.getSplitTestInfo(for: splitTestUniqueIdentifier) {
            return self.storage.getString(for: splitTestInfo.databaseKey)
        } else {
            return nil
        }
    }

    func setGroup(
        _ groupUniqueIdentifier: UniqueIdentifierType,
        splitTestUniqueIdentifier: UniqueIdentifierType
    ) {
        if let splitTestInfo = self.activeSplitTestInfoProvider.getSplitTestInfo(for: splitTestUniqueIdentifier) {
            self.storage.save(string: groupUniqueIdentifier, for: splitTestInfo.databaseKey)
        }
    }
}
