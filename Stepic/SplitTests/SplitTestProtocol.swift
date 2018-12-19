//
//  SplitTestProtocol.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

/// Represents specific instance of the split test.
///
/// Every split test may contain multiple groups that represented by `SplitTestGroupProtocol`.
/// Split test has the ability to set (send to analytics) the current group.
protocol SplitTestProtocol {
    associatedtype GroupType: SplitTestGroupProtocol
    /// A string identifier for analytics and storage keys.
    static var identifier: String { get }

    /// A boolean value that determines whether the split test may be using.
    /// - Returns: true if current app version is not smaller than `minParticipatingStartVersion`, otherwise false.
    static var shouldParticipate: Bool { get }
    static var minParticipatingStartVersion: String { get }

    /// Represents current assigned group for the split test instance.
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

    /// Sends current group to the analytics.
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
