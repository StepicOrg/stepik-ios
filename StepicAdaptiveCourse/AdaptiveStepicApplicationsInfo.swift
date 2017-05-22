//
//  AdaptiveStepicApplicationsInfo.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

struct StepicApplicationsInfo {
    
    static var social : ApplicationInfo? = ApplicationInfo(plist: "AdaptiveAuth", type: .social)
    static var password : ApplicationInfo? = ApplicationInfo(plist: "AdaptiveAuth", type: .password)
    
    static let urlScheme = "adaptive1838"
    
    static let apiURL = "https://stepik.org/api"
    static let oauthURL = "https://stepik.org/oauth2"
    static let stepicURL = "https://stepik.org"
    static let versionInfoURL = "https://stepik.org/media/attachments/lesson/26869/version.json"
    
    static let doesAllowCourseUnenrollment = true
    static let inAppUpdatesAvailable = false
    
    static let cookiePrefix = ""
    
    static let adaptiveCourseId = 1838
    
    static let streaksEnabled = false
    static let shouldRegisterNotifications = false
    
    static let appStoreRateURL = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1239082208&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&action=write-review")
    
    struct SocialInfo {
        struct AppIds {
            static let vk = "5995451"
            static let facebook = "171127739724012"
        }
    }
}
