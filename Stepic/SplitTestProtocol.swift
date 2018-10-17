//
//  SplitTestProtocol.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

protocol SplitTestProtocol {
    associatedtype GroupType: SplitTestGroupProtocol
    static var identifier: String { get }

    static var shouldParticipate: Bool { get }
    static var minParticipatingStartVersion: String { get }

    var currentGroup: GroupType { get }

    var analytics: ABAnalyticsServiceProtocol { get }
    init(currentGroup: GroupType, analytics: ABAnalyticsServiceProtocol)
}

extension SplitTestProtocol {
    static var shouldParticipate: Bool {
        let startVersion = DefaultsContainer.launch.startVersion
        return startVersion.compare(
            minParticipatingStartVersion,
            options: .numeric
        ) != .orderedAscending
    }

    func setSplitTestGroup() {
        self.analytics.setGroup(test: Self.analyticsKey, group: self.currentGroup.rawValue)
    }

    static var analyticsKey: String {
        return "split_test-\(self.identifier)"
    }

    static var dataBaseKey: String {
        return "split_test_database-\(self.identifier)"
    }
}
