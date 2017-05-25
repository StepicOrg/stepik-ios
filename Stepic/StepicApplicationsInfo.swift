//
//  StepicApplicationsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct StepicApplicationsInfo {
    
    static var social : ApplicationInfo? = ApplicationInfo(plist: "StepikAuth", type: .social)
    static var password : ApplicationInfo? = ApplicationInfo(plist: "StepikAuth", type: .password)

    static let urlScheme = "stepic"
    
    static let apiURL = "https://stepik.org/api"
    static let oauthURL = "https://stepik.org/oauth2"
    static let stepicURL = "https://stepik.org"
    static let versionInfoURL = "https://stepik.org/media/attachments/lesson/26869/version.json"
    
    static let cookiePrefix = ""

    static let doesAllowCourseUnenrollment = true
    static let inAppUpdatesAvailable = false
    
    static let streaksEnabled = true
    static let shouldRegisterNotifications = true
    
    static let isAdaptive = false
    
    
    static let appStoreRateURL = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1064581926&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&action=write-review")
    
    struct SocialInfo {
        struct AppIds {
            static let vk = "5628680"
            static let facebook = "171127739724012"
        }
    }
}
