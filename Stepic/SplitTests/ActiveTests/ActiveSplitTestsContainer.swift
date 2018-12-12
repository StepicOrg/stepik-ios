//
//  ActiveSplitTestsContainer.swift
//  Stepic
//
//  Created by Ostrenkiy on 16/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class ActiveSplitTestsContainer {
    private static let splitTestingService = SplitTestingService(analyticsService: AnalyticsUserProperties(), storage: UserDefaults.standard)

    static func setActiveTestsGroups() {
        self.splitTestingService.fetchSplitTest(AchievementPopupSplitTest.self).setSplitTestGroup()
    }
}
