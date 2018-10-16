//
//  AuthAfterOnboardingSplitTest.swift
//  Stepic
//
//  Created by Ostrenkiy on 16/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

final class AuthAfterOnboardingSplitTest: SplitTestProtocol {
    static var identifier: String = "auth_after_onboarding"
    static var minParticipatingStartVersion: String = "1.70"

    var currentGroup: AuthAfterOnboardingSplitTest.Group
    var analytics: ABAnalyticsServiceProtocol

    init(currentGroup: AuthAfterOnboardingSplitTest.Group, analytics: ABAnalyticsServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    typealias GroupType = Group

    enum Group: String, SplitTestGroupProtocol {
        case control = "control"
        case test = "test"

        static var groups: [AuthAfterOnboardingSplitTest.Group] = [.control, .test]
    }
}

extension AuthAfterOnboardingSplitTest.Group {
    var shouldShowAuth: Bool {
        switch self {
        case .control:
            return true
        case .test:
            return false
        }
    }
}
