//
//  ActiveSplitTestsContainer.swift
//  Stepic
//
//  Created by Ostrenkiy on 16/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ActiveSplitTestsContainer {
    private static let splitTestingService = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    /// A Dictionary where `key` is the split test identifier and `SplitTestInfo` associated with it.
    static let activeSplitTestsInfo = [
        RetentionLocalNotificationsSplitTest.identifier: getSplitTestInfo(RetentionLocalNotificationsSplitTest.self)
    ]

    static func setActiveTestsGroups() {
        self.splitTestingService.fetchSplitTest(RetentionLocalNotificationsSplitTest.self).setSplitTestGroup()
    }

    private static func getSplitTestInfo<Value: SplitTestProtocol>(
        _ splitTestType: Value.Type
    ) -> SplitTestInfo {
        return SplitTestInfo(
            title: String(describing: splitTestType),
            databaseKey: splitTestType.databaseKey,
            groups: splitTestType.GroupType.groups.map({ $0.rawValue })
        )
    }

    struct SplitTestInfo {
        let title: String
        let databaseKey: String
        let groups: [String]
    }
}
