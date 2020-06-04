//
//  AnalyticsUserProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Amplitude_iOS
import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation
import YandexMobileMetrica

final class AnalyticsUserProperties: ABAnalyticsServiceProtocol {
    static let shared = AnalyticsUserProperties()

    func setProperty(key: String, value: Any?) {
        if let v = value {
            Amplitude.instance().setUserProperties([key: v])
        } else {
            let identify = AMPIdentify().unset(key)
            Amplitude.instance().identify(identify)
        }
    }

    func setGroup(test: String, group: String) {
        self.setProperty(key: test, value: group)
    }

    private func setCrashlyticsProperty(key: String, value: Any?) {
        if let value = value {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }

    private func incrementAmplitudeProperty(key: String, value: Int = 1) {
        let identify = AMPIdentify().add(key, value: value as NSObject)
        Amplitude.instance().identify(identify)
    }

    func clearUserDependentProperties() {
        setUserID(to: nil)
        setCoursesCount(count: nil)
    }

    func setUserID(to id: Int?) {
        setProperty(key: "stepik_id", value: id)
        setCrashlyticsProperty(key: "stepik_id", value: id)

        let userProfileID: String? = id != nil ? String(id.require()) : nil
        // Update AppMetrica user profile id.
        YMMYandexMetrica.setUserProfileID(userProfileID)
        // Update FirebaseAnalytics user profile id.
        FirebaseAnalytics.Analytics.setUserID(userProfileID)
    }

    func incrementSubmissionsCount() {
        incrementAmplitudeProperty(key: "submissions_count")
    }

    func decrementCoursesCount() {
        incrementAmplitudeProperty(key: "courses_count", value: -1)
    }

    func incrementCoursesCount() {
        incrementAmplitudeProperty(key: "courses_count")
    }

    func setCoursesCount(count: Int?) {
        setProperty(key: "courses_count", value: count)
    }

    func setPushPermissionStatus(_ status: NotificationPermissionStatus) {
        let key = "push_permission"

        switch status {
        case .authorized:
            self.setProperty(key: key, value: "granted")
        case .denied:
            self.setProperty(key: key, value: "not_granted")
        case .notDetermined:
            self.setProperty(key: key, value: "not_determined")
        }
    }

    func setStreaksNotificationsEnabled(_ enabled: Bool) {
        self.setProperty(key: "streaks_notifications_enabled", value: enabled ? "enabled" : "disabled")
    }

    func setScreenOrientation(isPortrait: Bool) {
        setProperty(key: "screen_orientation", value: isPortrait ? "portrait" : "landscape")
    }

    func setApplicationID(id: String) {
        setProperty(key: "application_id", value: id)
    }

    func updateUserID() {
        self.setUserID(to: AuthInfo.shared.userId)
    }

    func updateIsDarkModeEnabled() {
        let isEnabled: Bool = {
            if #available(iOS 13.0, *) {
                if case .dark = UITraitCollection.current.userInterfaceStyle {
                    return true
                }
            }
            return false
        }()

        self.setProperty(key: "is_night_mode_enabled", value: "\(isEnabled)")
    }
}
