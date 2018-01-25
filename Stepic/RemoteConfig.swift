//
//  RemoteConfig.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Firebase

enum RemoteConfigKeys: String {
    case showStreaksNotificationTrigger = "show_streaks_notification_trigger"
    case adaptiveBackendUrl = "adaptive_backend_url"
    case supportedInAdaptiveModeCourses = "adaptive_courses_ios"
}

class RemoteConfig {
    private let defaultShowStreaksNotificationTrigger = ShowStreaksNotificationTrigger.loginAndSubmission
    static let shared = RemoteConfig()

    var loadingDoneCallback: (() -> Void)?
    var fetchComplete: Bool = false

    enum ShowStreaksNotificationTrigger: String {
        case loginAndSubmission = "login_and_submission"
        case submission = "submission"
    }

    var showStreaksNotificationTrigger: ShowStreaksNotificationTrigger {
        guard let configValue = FIRRemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKeys.showStreaksNotificationTrigger.rawValue).stringValue else {
            return defaultShowStreaksNotificationTrigger
        }
        return ShowStreaksNotificationTrigger(rawValue: configValue) ?? defaultShowStreaksNotificationTrigger
    }

    var adaptiveBackendUrl: String {
        guard let configValue = FIRRemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKeys.adaptiveBackendUrl.rawValue).stringValue else {
            return StepicApplicationsInfo.adaptiveRatingURL
        }

        return configValue
    }

    var supportedInAdaptiveModeCourses: [Int] {
        guard let configValue = FIRRemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKeys.supportedInAdaptiveModeCourses.rawValue).stringValue else {
            return StepicApplicationsInfo.adaptiveSupportedCourses
        }

        let ids = configValue.components(separatedBy: ",").flatMap { Int($0) }
        return ids
    }

    init() {
        loadDefaultValues()
        fetchCloudValues()
    }

    func setup() {}

    private func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            RemoteConfigKeys.showStreaksNotificationTrigger.rawValue: defaultShowStreaksNotificationTrigger.rawValue as NSObject,
            RemoteConfigKeys.adaptiveBackendUrl.rawValue: StepicApplicationsInfo.adaptiveRatingURL as NSObject,
            RemoteConfigKeys.supportedInAdaptiveModeCourses.rawValue: StepicApplicationsInfo.adaptiveSupportedCourses as NSObject
        ]
        FIRRemoteConfig.remoteConfig().setDefaults(appDefaults)
    }

    private func fetchCloudValues() {
        let fetchDuration: TimeInterval = 43200
        #if DEBUG
            activateDebugMode()
        #endif
        FIRRemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) {
            [weak self]
            _, error in

            guard error == nil else {
                print ("Got an error fetching remote values \(String(describing: error))")
                return
            }

            FIRRemoteConfig.remoteConfig().activateFetched()

            self?.fetchComplete = true
            self?.loadingDoneCallback?()
        }
    }

    private func activateDebugMode() {
        let debugSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        FIRRemoteConfig.remoteConfig().configSettings = debugSettings!
    }
}
