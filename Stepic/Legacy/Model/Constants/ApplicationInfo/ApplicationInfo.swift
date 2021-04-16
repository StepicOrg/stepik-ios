//
//  ApplicationInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class ApplicationInfo {
    enum Path {
        enum URL {
            static let appId = "url.appId"
            static let scheme = "url.scheme"
            static let api = "url.api"
            static let oauth = "url.oauth"
            static let stepik = "url.stepik"
            static let host = "url.host"
            static let adaptiveRating = "url.adaptiveRating"
        }
        enum Cookie {
            static let prefix = "cookie.prefix"
        }
        enum Feature {
            static let courseUnenrollment = "feature.courseUnenrollment"
            static let streaks = "feature.streaks"
            static let notifications = "feature.notifications"
        }
        enum Adaptive {
            static let supportedCourses = "adaptive.supportedCourses"
            static let isAdaptive = "adaptive.isAdaptive"
            static let mainColor = "adaptive.mainColor"
            static let coursesInfoURL = "adaptive.coursesInfoURL"
        }
        enum RateApp {
            static let submissionsThreshold = "rateApp.submissionsThreshold"
            static let appStoreLink = "rateApp.appStoreLink"
        }
        enum SocialProviders {
            static let vkId = "socialProviders.vk"
            static let facebookId = "socialProviders.facebook"
            static let googleId = "socialProviders.google"
        }
        enum AuthType {
            static let social = "social"
            static let password = "password"
            enum Social {
                static let id = "social.id"
                static let secret = "social.secret"
                static let redirect = "social.redirect_uri"
            }
            enum Password {
                static let id = "password.id"
                static let secret = "password.secret"
                static let redirect = "password.redirect_uri"
            }
        }
        enum Modules {
            static let tabs = "modules.tabs"
        }
        enum Versions {
            static let stories = "versions.stories"
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
