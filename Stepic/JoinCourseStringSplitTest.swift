//
//  JoinCourseStringSplitTest.swift
//  Stepic
//
//  Created by Ostrenkiy on 26/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

final class JoinCourseStringSplitTest: SplitTestProtocol {
    typealias GroupType = Group

    static var identifier = "join_course_string"
    static var minParticipatingStartVersion = "1.71"

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

        var joinText: String {
            switch self {
            case .control:
                return NSLocalizedString("WidgetButtonJoin", comment: "")
            case .test:
                return NSLocalizedString("WidgetButtonJoinTest", comment: "")
            }
        }
    }
}
