//
//  AchievementPopupSplitTest.swift
//  Stepic
//
//  Created by Ivan Magda on 11/28/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AchievementPopupSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static let identifier = "achievement_popup"
    static let minParticipatingStartVersion = "1.73"

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

        var isParticipant: Bool {
            switch self {
            case .control:
                return false
            case .test:
                return true
            }
        }
    }
}
