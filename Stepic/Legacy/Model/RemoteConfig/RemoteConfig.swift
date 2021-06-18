//
//  RemoteConfig.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import DeviceKit
import FirebaseRemoteConfig
import Foundation

final class RemoteConfig {
    private static let defaultShowStreaksNotificationTrigger = ShowStreaksNotificationTrigger.loginAndSubmission
    static let shared = RemoteConfig()

    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false

    var fetchDuration: TimeInterval = 43200

    lazy var appDefaults: [String: NSObject] = [
        Key.showStreaksNotificationTrigger.rawValue: NSString(string: Self.defaultShowStreaksNotificationTrigger.rawValue),
        Key.adaptiveBackendUrl.rawValue: NSString(string: StepikApplicationsInfo.adaptiveRatingURL),
        Key.supportedInAdaptiveModeCourses.rawValue: NSArray(array: StepikApplicationsInfo.adaptiveSupportedCourses),
        Key.newLessonAvailable.rawValue: NSNumber(value: true),
        Key.darkModeAvailable.rawValue: NSNumber(value: true),
        Key.arQuickLookAvailable.rawValue: NSNumber(value: false),
        Key.isDisabledStepsSupported.rawValue: NSNumber(value: false),
        Key.searchResultsQueryParams.rawValue: NSDictionary(dictionary: ["is_popular": "true", "is_public": "true"]),
        Key.isCoursePricesEnabled.rawValue: NSNumber(value: false)
    ]

    var showStreaksNotificationTrigger: ShowStreaksNotificationTrigger {
        guard let configValue = FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(
            forKey: Key.showStreaksNotificationTrigger.rawValue
        ).stringValue else {
            return Self.defaultShowStreaksNotificationTrigger
        }

        return ShowStreaksNotificationTrigger(rawValue: configValue) ?? Self.defaultShowStreaksNotificationTrigger
    }

    var adaptiveBackendURL: String {
        guard let configValue = FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(
            forKey: Key.adaptiveBackendUrl.rawValue
        ).stringValue else {
            return StepikApplicationsInfo.adaptiveRatingURL
        }

        return configValue
    }

    var supportedInAdaptiveModeCourses: [Course.IdType] {
        guard let configValue = FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(
            forKey: Key.supportedInAdaptiveModeCourses.rawValue
        ).stringValue else {
            return StepikApplicationsInfo.adaptiveSupportedCourses
        }

        let courses = configValue.components(separatedBy: ",")
        var supportedCourses = [String]()

        for course in courses {
            let parts = course.components(separatedBy: "-")
            if parts.count == 1 {
                let courseId = parts[0]
                supportedCourses.append(courseId)
            } else if parts.count == 2 {
                let courseId = parts[0]
                if let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String,
                   let buildNum = Int(build),
                   let minimalBuild = Int(parts[1]) {
                    if buildNum >= minimalBuild {
                        supportedCourses.append(courseId)
                    }
                }
            }
        }

        return supportedCourses.compactMap { Int($0) }
    }

    var isDarkModeAvailable: Bool {
        if DeviceInfo.current.OSVersion.major < 13 {
            return false
        }

        return FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.darkModeAvailable.rawValue)
            .boolValue
    }

    var isARQuickLookAvailable: Bool {
        FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.arQuickLookAvailable.rawValue)
            .boolValue
    }

    var isDisabledStepsSupported: Bool {
        FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.isDisabledStepsSupported.rawValue)
            .boolValue
    }

    var searchResultsQueryParams: JSONDictionary {
        guard let configValue = FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(
            forKey: Key.searchResultsQueryParams.rawValue
        ).jsonValue, let params = configValue as? JSONDictionary else {
            return self.appDefaults[Key.searchResultsQueryParams.rawValue] as? JSONDictionary ?? [:]
        }

        return params
    }

    var isCoursePricesEnabled: Bool {
        FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.isCoursePricesEnabled.rawValue)
            .boolValue
    }

    init() {
        self.setConfigDefaults()
        self.fetchRemoteConfigData()
    }

    func setup() {}

    // MARK: Private API

    private func setConfigDefaults() {
        FirebaseRemoteConfig.RemoteConfig.remoteConfig().setDefaults(self.appDefaults)
    }

    private func fetchRemoteConfigData() {
        #if DEBUG
        self.activateDebugMode()
        #endif

        FirebaseRemoteConfig.RemoteConfig.remoteConfig().fetch(
            withExpirationDuration: self.fetchDuration
        ) { [weak self] _, error in
            guard error == nil else {
                return print("RemoteConfig :: Got an error fetching remote values \(String(describing: error))")
            }

            FirebaseRemoteConfig.RemoteConfig.remoteConfig().activate { changed, error in
                if let error = error {
                    print("RemoteConfig :: failed activate remote config with error: \(error)")
                } else {
                    print("RemoteConfig :: activated remote config, changed: \(changed)")
                }
            }

            self?.fetchComplete = true
            self?.loadingDoneCallback?()
        }
    }

    private func activateDebugMode() {
        self.fetchDuration = 0
        let debugSettings = RemoteConfigSettings()
        debugSettings.minimumFetchInterval = 0
        FirebaseRemoteConfig.RemoteConfig.remoteConfig().configSettings = debugSettings
    }

    // MARK: Inner Types

    enum ShowStreaksNotificationTrigger: String {
        case loginAndSubmission = "login_and_submission"
        case submission = "submission"
    }

    enum Key: String {
        case showStreaksNotificationTrigger = "show_streaks_notification_trigger"
        case adaptiveBackendUrl = "adaptive_backend_url"
        case supportedInAdaptiveModeCourses = "supported_adaptive_courses_ios"
        case newLessonAvailable = "new_lesson_available_ios"
        case darkModeAvailable = "is_dark_mode_available_ios"
        case arQuickLookAvailable = "is_ar_quick_look_available_ios"
        case isDisabledStepsSupported = "is_disabled_steps_supported"
        case searchResultsQueryParams = "search_query_params_ios"
        case isCoursePricesEnabled = "is_course_prices_enabled_ios"
    }
}
