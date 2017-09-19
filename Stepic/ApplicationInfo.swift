//
//  ApplicationInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

class ApplicationInfo {

    struct Path {
        struct URL {
            static let appId = "url.appId"
            static let scheme = "url.scheme"
            static let api = "url.api"
            static let oauth = "url.oauth"
            static let stepik = "url.stepik"
            static let version = "url.version"
        }
        struct Cookie {
            static let prefix = "cookie.prefix"
        }
        struct Feature {
            static let courseUnenrollment = "feature.courseUnenrollment"
            static let inAppUpdates = "feature.inAppUpdates"
            static let streaks = "feature.streaks"
            static let notifications = "feature.notifications"
        }
        struct Adaptive {
            static let isAdaptive = "adaptive.isAdaptive"
            static let courseId = "adaptive.courseId"
            static let mainColor = "adaptive.mainColor"
            static let ratingURL = "adaptive.ratingURL"
        }
        struct RateApp {
            static let submissionsThreshold = "rateApp.submissionsThreshold"
            static let appStoreLink = "rateApp.appStoreLink"
        }
        struct SocialProviders {
            static let vkId = "socialProviders.vk"
            static let facebookId = "socialProviders.facebook"
        }
        struct AuthType {
            static let social = "social"
            static let password = "password"
            struct Social {
                static let id = "social.id"
                static let secret = "social.secret"
                static let redirect = "social.redirect_uri"
            }
            struct Password {
                static let id = "password.id"
                static let secret = "password.secret"
                static let redirect = "password.redirect_uri"
            }
        }
        struct Colors {
            static let mainText = "colors.mainText"
            static let mainDark = "colors.mainDark"
        }
        struct Modules {
            static let tabs = "modules.tabs"
        }
    }

    private var settings: NSDictionary?

    convenience init?(plist: String) {
        self.init()
        let bundle = Bundle(for: type(of: self) as AnyClass)
        guard let path = bundle.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        guard let dic = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        self.settings = dic
    }

    func get(for path: String) -> Any? {
        guard let dic = settings else {
            return nil
        }
        return dic.value(forKeyPath: path)
    }

    func has(path: String) -> Bool {
        guard let dic = settings else {
            return false
        }
        return dic.value(forKeyPath: path) != nil
    }
}
