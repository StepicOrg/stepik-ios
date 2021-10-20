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
    private static let analyticsUserPropertyKeyPrefix = "remote_config_"

    private static let defaultShowStreaksNotificationTrigger = ShowStreaksNotificationTrigger.loginAndSubmission

    private static let defaultCoursePurchaseFlowType = CoursePurchaseFlowType.web

    static let shared = RemoteConfig()

    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false

    var fetchDuration: TimeInterval = 43200

    lazy var appDefaults: [String: NSObject] = [
        Key.showStreaksNotificationTrigger.rawValue: NSString(string: Self.defaultShowStreaksNotificationTrigger.rawValue),
        Key.adaptiveBackendUrl.rawValue: NSString(string: StepikApplicationsInfo.adaptiveRatingURL),
        Key.supportedInAdaptiveModeCourses.rawValue: NSArray(array: StepikApplicationsInfo.adaptiveSupportedCourses),
        Key.arQuickLookAvailable.rawValue: NSNumber(value: false),
        Key.searchResultsQueryParams.rawValue: NSDictionary(dictionary: ["is_popular": "true", "is_public": "true"]),
        Key.isCoursePricesEnabled.rawValue: NSNumber(value: false),
        Key.isCourseRevenueAvailable.rawValue: NSNumber(value: false),
        Key.purchaseFlow.rawValue: NSString(string: Self.defaultCoursePurchaseFlowType.rawValue)
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

    var isARQuickLookAvailable: Bool {
        FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.arQuickLookAvailable.rawValue)
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
        #if BETA_PROFILE || DEBUG
        return true
        #else
        return FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.isCoursePricesEnabled.rawValue)
            .boolValue
        #endif
    }

    var isCourseRevenueAvailable: Bool {
        #if BETA_PROFILE || DEBUG
        return true
        #else
        return FirebaseRemoteConfig.RemoteConfig
            .remoteConfig()
            .configValue(forKey: Key.isCourseRevenueAvailable.rawValue)
            .boolValue
        #endif
    }

    var coursePurchaseFlow: CoursePurchaseFlowType {
        guard let configValue = FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(
            forKey: Key.purchaseFlow.rawValue
        ).stringValue else {
            return Self.defaultCoursePurchaseFlowType
        }

        return CoursePurchaseFlowType(rawValue: configValue) ?? Self.defaultCoursePurchaseFlowType
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

            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchComplete = true
            strongSelf.loadingDoneCallback?()
            strongSelf.updateAnalyticsUserProperties()
        }
    }

    private func activateDebugMode() {
        self.fetchDuration = 0
        let debugSettings = RemoteConfigSettings()
        debugSettings.minimumFetchInterval = 0
        FirebaseRemoteConfig.RemoteConfig.remoteConfig().configSettings = debugSettings
    }

    private func updateAnalyticsUserProperties() {
        let userProperties: [String: Any] = [
            Key.showStreaksNotificationTrigger.analyticsUserPropertyKey: self.showStreaksNotificationTrigger.rawValue,
            Key.adaptiveBackendUrl.analyticsUserPropertyKey: self.adaptiveBackendURL,
            Key.supportedInAdaptiveModeCourses.analyticsUserPropertyKey: self.supportedInAdaptiveModeCourses,
            Key.arQuickLookAvailable.analyticsUserPropertyKey: self.isARQuickLookAvailable,
            Key.searchResultsQueryParams.analyticsUserPropertyKey: self.searchResultsQueryParams,
            Key.isCoursePricesEnabled.analyticsUserPropertyKey: self.isCoursePricesEnabled,
            Key.isCourseRevenueAvailable.analyticsUserPropertyKey: self.isCourseRevenueAvailable
        ]
        AnalyticsUserProperties.shared.setRemoteConfigUserProperties(userProperties)
    }

    // MARK: Inner Types

    enum ShowStreaksNotificationTrigger: String {
        case loginAndSubmission = "login_and_submission"
        case submission = "submission"
    }

    private enum Key: String {
        case showStreaksNotificationTrigger = "show_streaks_notification_trigger"
        case adaptiveBackendUrl = "adaptive_backend_url"
        case supportedInAdaptiveModeCourses = "supported_adaptive_courses_ios"
        case arQuickLookAvailable = "is_ar_quick_look_available_ios"
        case searchResultsQueryParams = "search_query_params_ios"
        case isCoursePricesEnabled = "is_course_prices_enabled_ios"
        case isCourseRevenueAvailable = "is_course_revenue_available_ios"
        case purchaseFlow = "purchase_flow_ios"

        var analyticsUserPropertyKey: String { "\(RemoteConfig.analyticsUserPropertyKeyPrefix)\(self.rawValue)" }
    }
}
