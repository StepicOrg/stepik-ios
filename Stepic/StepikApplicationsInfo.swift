//
//  StepicApplicationsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

struct StepikApplicationsInfo {
    // Dictionary with auth (encrypted)
    private static let stepikAuthDic = ApplicationInfo(plist: "Auth")
    // Dictionary with configuration
    private static let stepikConfigDic = ApplicationInfo(plist: "Config")

    // Structure
    typealias Root = ApplicationInfo.Path

    // Section: AuthInfo
    typealias AuthInfo = (clientId: String, clientSecret: String, redirectUri: String, credentials: String)

    private static func initAuthInfo(idPath: String, secretPath: String, redirectPath: String) -> AuthInfo {
        let id = StepikApplicationsInfo.stepikAuthDic?.get(for: idPath) as? String ?? ""
        let secret = StepikApplicationsInfo.stepikAuthDic?.get(for: secretPath) as? String ?? ""
        let redirect = StepikApplicationsInfo.stepikAuthDic?.get(for: redirectPath) as? String ?? ""
        let credentials = "\(id):\(secret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
        return (clientId: id, clientSecret: secret, redirectUri: redirect, credentials: credentials)
    }

    static let social: AuthInfo? = !(StepikApplicationsInfo.stepikAuthDic?.has(path: Root.AuthType.social) ?? false)
        ? nil
        : StepikApplicationsInfo.initAuthInfo(
            idPath: Root.AuthType.Social.id,
            secretPath: Root.AuthType.Social.secret,
            redirectPath: Root.AuthType.Social.redirect
          )

    static let password: AuthInfo? = !(StepikApplicationsInfo.stepikAuthDic?.has(path: Root.AuthType.password) ?? false)
        ? nil
        : StepikApplicationsInfo.initAuthInfo(
            idPath: Root.AuthType.Password.id,
            secretPath: Root.AuthType.Password.secret,
            redirectPath: Root.AuthType.Password.redirect
          )

    // Section: URL
    static let appId = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.appId) as? String ?? ""
    static let urlScheme = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.scheme) as? String ?? ""
    static let apiURL = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.api) as? String ?? ""
    static let oauthURL = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.oauth) as? String ?? ""
    static let stepicURL = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.stepik) as? String ?? ""
    static let versionInfoURL = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.version) as? String ?? ""
    static let adaptiveRatingURL = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.URL.adaptiveRating) as? String ?? ""

    // Section: Cookie
    static let cookiePrefix = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Cookie.prefix) as? String ?? ""

    // Section: Feature
    static let doesAllowCourseUnenrollment = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.courseUnenrollment) as? Bool ?? true
    static let inAppUpdatesAvailable = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.inAppUpdates) as? Bool ?? false
    static let streaksEnabled = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.streaks) as? Bool ?? true
    static let shouldRegisterNotifications = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.notifications) as? Bool ?? true

    // Section: Adaptive
    static let adaptiveSupportedCourses = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Adaptive.supportedCourses) as? [Int] ?? []
    static let isAdaptive = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Adaptive.isAdaptive) as? Bool ?? false
    static let adaptiveCoursesInfoURL = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Adaptive.coursesInfoURL) as? String ?? ""

    // Section: RateApp
    struct RateApp {
        static let correctSubmissionsThreshold = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.RateApp.submissionsThreshold) as? Int ?? 4
        static let appStoreURL = URL(string: StepikApplicationsInfo.stepikConfigDic?.get(for: Root.RateApp.appStoreLink) as? String ?? "")
    }

    // Section: Social
    struct SocialInfo {
        struct AppIds {
            static let vk = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.SocialProviders.vkId) as? String ?? ""
            static let facebook = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.SocialProviders.facebookId) as? String ?? ""
        }
    }

    // Section: Colors
    struct Colors {
        static var mainGreen = UIColor(hex: StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Colors.mainGreen) as? Int ?? 0x66cc66)
        static var mainText = UIColor(hex: StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Colors.mainText) as? Int ?? 0x000000)
        static var mainDark = UIColor(hex: StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Colors.mainDark) as? Int ?? 0x000000)
    }

    // Section: Modules
    struct Modules {
        static let tabs = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Modules.tabs) as? [String]
    }

    // Section: Versions
    struct Versions {
        static let stories = StepikApplicationsInfo.stepikConfigDic?.get(for: Root.Versions.stories) as? Int
    }
}
