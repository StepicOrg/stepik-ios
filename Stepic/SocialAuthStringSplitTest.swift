//
//  SocialAuthStringSplitTest.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation
import UIKit

final class SocialAuthStringSplitTest: SplitTestProtocol {
    static var identifier: String = "social_auth_string"

    var currentGroup: SocialAuthStringSplitTest.Group
    var analytics: AnalyticsUserPropertiesServiceProtocol

    init(currentGroup: SocialAuthStringSplitTest.Group, analytics: AnalyticsUserPropertiesServiceProtocol) {
        self.currentGroup = currentGroup
        self.analytics = analytics
    }

    typealias GroupType = Group

    enum Group: String, SplitTestGroupProtocol {
        case control = "control"
        case test = "test"

        static var groups: [SocialAuthStringSplitTest.Group] = [.control, .test]
    }
}

extension SocialAuthStringSplitTest.Group {
    var authString: String {
        switch self {
        case .control:
            return NSLocalizedString("SignInTitleSocial", comment: "")
        case .test:
            return NSLocalizedString("SignInTitleSocialTest", comment: "")
        }
    }
}
