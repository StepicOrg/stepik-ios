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

    func setGroup(test: String, group: String) {
        self.setAmplitudeProperty(key: test, value: group)
        // AppMetrica
        let userProfile = YMMMutableUserProfile()
        let groupAttribute = YMMProfileAttribute.customString(test)
        userProfile.apply(groupAttribute.withValue(group))
        YMMYandexMetrica.report(userProfile, onFailure: nil)
    }

    func setAmplitudeProperty(key: String, value: Any?) {
        if let value = value {
            Amplitude.instance().setUserProperties([key: value])
        } else {
            let identify = AMPIdentify().unset(key)
            Amplitude.instance().identify(identify)
        }
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
        self.setUserID(to: nil)
        self.setCoursesCount(count: nil)
    }

    func setUserID(to id: Int?) {
        self.setAmplitudeProperty(key: "stepik_id", value: id)
        self.setCrashlyticsProperty(key: "stepik_id", value: id)

        let userProfileID: String? = id != nil ? String(id.require()) : nil
        // Update AppMetrica user profile id.
        YMMYandexMetrica.setUserProfileID(userProfileID)
        // Update FirebaseAnalytics user profile id.
        FirebaseAnalytics.Analytics.setUserID(userProfileID)
    }

    func incrementSubmissionsCount() {
        self.incrementAmplitudeProperty(key: "submissions_count")
    }

    func decrementCoursesCount() {
        self.incrementAmplitudeProperty(key: "courses_count", value: -1)
    }

    func incrementCoursesCount() {
        self.incrementAmplitudeProperty(key: "courses_count")
    }

    func setCoursesCount(count: Int?) {
        self.setAmplitudeProperty(key: "courses_count", value: count)
    }

    func setPushPermissionStatus(_ status: NotificationPermissionStatus) {
        let key = "push_permission"

        switch status {
        case .authorized:
            self.setAmplitudeProperty(key: key, value: "granted")
        case .denied:
            self.setAmplitudeProperty(key: key, value: "not_granted")
        case .notDetermined:
            self.setAmplitudeProperty(key: key, value: "not_determined")
        }
    }

    func setStreaksNotificationsEnabled(_ enabled: Bool) {
        self.setAmplitudeProperty(key: "streaks_notifications_enabled", value: enabled ? "enabled" : "disabled")
    }

    func setScreenOrientation(isPortrait: Bool) {
        self.setAmplitudeProperty(key: "screen_orientation", value: isPortrait ? "portrait" : "landscape")
    }

    func setApplicationID(id: String) {
        self.setAmplitudeProperty(key: "application_id", value: id)
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

        self.setAmplitudeProperty(key: "is_night_mode_enabled", value: "\(isEnabled)")
    }
}
