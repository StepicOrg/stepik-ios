//
//  ActiveSplitTestInfoProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 12/24/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct SplitTestInfo {
    let title: String
    let databaseKey: String
    let groups: [String]
}

extension SplitTestInfo {
    init<Value: SplitTestProtocol>(_ splitTestType: Value.Type) {
        self.title = splitTestType.displayName
        self.databaseKey = splitTestType.databaseKey
        self.groups = splitTestType.GroupType.groups.map { $0.rawValue }
    }
}

protocol ActiveSplitTestInfoProvider {
    var activeSplitTestInfos: [UniqueIdentifierType: SplitTestInfo] { get }
}

extension ActiveSplitTestInfoProvider {
    func getSplitTestsUniqueIdentifiers() -> [UniqueIdentifierType] {
        return Array(self.activeSplitTestInfos.keys)
    }

    func getSplitTestInfo(for splitTestUniqueIdentifier: UniqueIdentifierType) -> SplitTestInfo? {
        return self.activeSplitTestInfos[splitTestUniqueIdentifier]
    }
}
