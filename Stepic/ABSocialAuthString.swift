//
//  ABSocialAuthString.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class ABSocialAuthString: ActiveABTest {
    let ID = "ab_social_auth_string"

    let controlValue: String = NSLocalizedString("SignInTitleSocial", comment: "")

    func value(group: String) -> String? {
        switch group {
        case "control":
            return controlValue
        case "test":
            return NSLocalizedString("SignInTitleSocialTest", comment: "")
        default:
            return nil
        }
    }
}
