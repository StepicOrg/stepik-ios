import Amplitude
import AppMetricaCore
import FirebaseAnalytics
import FirebaseCrashlytics
import UIKit

final class AnalyticsUserProperties: ABAnalyticsServiceProtocol {
    static let shared = AnalyticsUserProperties()

    // MARK: ABAnalyticsServiceProtocol

    func setGroup(test: String, group: String) {
        self.setAmplitudeProperty(key: test, value: group)
        // AppMetrica
        let userProfile = MutableUserProfile()
        let groupAttribute = ProfileAttribute.customString(test)
        userProfile.apply(groupAttribute.withValue(group))
        AppMetrica.reportUserProfile(userProfile, onFailure: nil)
    }

    // MARK: Public API

    func clearUserDependentProperties() {
        self.setUserID(to: nil)
        self.setCoursesCount(count: nil)
    }

    func setUserID(to id: Int?) {
        self.setAmplitudeProperty(key: UserPropertyKey.stepikID.rawValue, value: id)
        self.setCrashlyticsProperty(key: UserPropertyKey.stepikID.rawValue, value: id)

        let userProfileID: String? = id != nil ? String(id.require()) : nil
        // Update AppMetrica user profile id.
        AppMetrica.userProfileID = userProfileID
        // Update FirebaseAnalytics user profile id.
        FirebaseAnalytics.Analytics.setUserID(userProfileID)
    }

    func incrementSubmissionsCount() {
        self.incrementAmplitudeProperty(key: UserPropertyKey.submissionsCount.rawValue)
    }

    func decrementCoursesCount() {
        self.incrementAmplitudeProperty(key: UserPropertyKey.coursesCount.rawValue, value: -1)
    }

    func incrementCoursesCount() {
        self.incrementAmplitudeProperty(key: UserPropertyKey.coursesCount.rawValue)
    }

    func setCoursesCount(count: Int?) {
        self.setAmplitudeProperty(key: UserPropertyKey.coursesCount.rawValue, value: count)
    }

    func setPushPermissionStatus(_ status: NotificationPermissionStatus) {
        let statusStringValue: String = {
            switch status {
            case .authorized:
                return "granted"
            case .denied:
                return "not_granted"
            case .notDetermined:
                return "not_determined"
            }
        }()

        self.setAmplitudeProperty(key: UserPropertyKey.pushPermission.rawValue, value: statusStringValue)
    }

    func setStreaksNotificationsEnabled(_ enabled: Bool) {
        self.setAmplitudeProperty(
            key: UserPropertyKey.streaksNotificationsEnabled.rawValue,
            value: enabled ? "enabled" : "disabled"
        )
    }

    func setScreenOrientation(isPortrait: Bool) {
        self.setAmplitudeProperty(
            key: UserPropertyKey.screenOrientation.rawValue,
            value: isPortrait ? "portrait" : "landscape"
        )
    }

    func setApplicationID(id: String) {
        self.setAmplitudeProperty(key: UserPropertyKey.applicationID.rawValue, value: id)
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

        self.setAmplitudeProperty(key: UserPropertyKey.isNightModeEnabled.rawValue, value: "\(isEnabled)")
    }

    func updateAccessibilityIsVoiceOverRunning() {
        self.setAmplitudeProperty(
            key: UserPropertyKey.isAccessibilityScreenReaderEnabled.rawValue,
            value: UIAccessibility.isVoiceOverRunning
        )
    }

    func updateAccessibilityFontScale() {
        guard #available(iOS 13.0, *) else {
            return
        }

        let defaultBodyFont = UIFont.preferredFont(
            forTextStyle: .body,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
        )

        let currentBodyFont = UIFont.preferredFont(
            forTextStyle: .body,
            compatibleWith: UITraitCollection.current
        )

        let fontScale = currentBodyFont.pointSize / defaultBodyFont.pointSize

        self.setAmplitudeProperty(key: UserPropertyKey.accessibilityFontScale.rawValue, value: fontScale)
    }

    func setRemoteConfigUserProperties(_ keysAndValues: [String: Any]) {
        Amplitude.instance().setUserProperties(keysAndValues)
        Crashlytics.crashlytics().setCustomKeysAndValues(keysAndValues)
        self.setYandexMetricaProfileAttributes(keysAndValues)
    }

    // MARK: Private API

    private func setAmplitudeProperty(key: String, value: Any?) {
        if let value = value {
            Amplitude.instance().setUserProperties([key: value])
        } else if let identify = AMPIdentify().unset(key) {
            Amplitude.instance().identify(identify)
        }
    }

    private func incrementAmplitudeProperty(key: String, value: Int = 1) {
        if let identify = AMPIdentify().add(key, value: value as NSObject) {
            Amplitude.instance().identify(identify)
        }
    }

    private func setCrashlyticsProperty(key: String, value: Any?) {
        if let value = value {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }

    private func setYandexMetricaProfileAttributes(_ profileAttributes: [String: Any]) {
        let userProfileUpdates = profileAttributes.map { key, value -> UserProfileUpdate in
            if let boolValue = value as? Bool {
                return ProfileAttribute.customBool(key).withValue(boolValue)
            } else if let doubleValue = value as? Double {
                return ProfileAttribute.customNumber(key).withValue(doubleValue)
            } else {
                return ProfileAttribute.customString(key).withValue(String(describing: value))
            }
        }

        let userProfile = MutableUserProfile()
        userProfile.apply(from: userProfileUpdates)
        AppMetrica.reportUserProfile(userProfile) { error in
            print("AnalyticsUserProperties :: AppMetrica :: failed report userProfile with error = \(error)")
        }
    }

    // MARK: Inner Types

    private enum UserPropertyKey: String {
        case stepikID = "stepik_id"
        case submissionsCount = "submissions_count"
        case coursesCount = "courses_count"
        case pushPermission = "push_permission"
        case streaksNotificationsEnabled = "streaks_notifications_enabled"
        case screenOrientation = "screen_orientation"
        case applicationID = "application_id"
        case isNightModeEnabled = "is_night_mode_enabled"
        case isAccessibilityScreenReaderEnabled = "accessibility_screen_reader_enabled"
        case accessibilityFontScale = "accessibility_font_scale"
    }
}
