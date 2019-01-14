//
// RetentionLocalNotificationsSplitTest.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-12-11.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

final class RetentionLocalNotificationsSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "retention_local_notification"
    static let minParticipatingStartVersion = "1.74"

    var currentGroup: Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol {
        case control = "control"
        case test = "test"

        static var groups: [Group] = [.control, .test]

        var shouldReceiveNotifications: Bool {
            switch self {
            case .control:
                return false
            case .test:
                return true
            }
        }
    }
}
