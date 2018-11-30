//
// SubscribeNotificationsOnLaunchSplitTest.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-11-26.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

final class SubscribeNotificationsOnLaunchSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static var identifier = "subscribe_notifications_on_launch"
    static var minParticipatingStartVersion = "1.73"

    var currentGroup: SubscribeNotificationsOnLaunchSplitTest.Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: GroupType, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    enum Group: String, SplitTestGroupProtocol {
        case control = "control"
        case test = "test"

        static var groups: [Group] = [.control, .test]

        var shouldShowOnFirstLaunch: Bool {
            switch self {
            case .control:
                return false
            case .test:
                return true
            }
        }
    }
}
