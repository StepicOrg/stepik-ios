import FirebaseRemoteConfig
import Foundation
import Nuke

protocol RemoteConfigDelegate: AnyObject {
    func remoteConfig(_ remoteConfig: RemoteConfig, configValueForKey key: RemoteConfig.Key) -> Any?
}

final class RemoteConfig {
    private static let analyticsUserPropertyKeyPrefix = "remote_config_"

    private static let defaultShowStreaksNotificationTrigger = ShowStreaksNotificationTrigger.loginAndSubmission

    private static let defaultCoursePurchaseFlowType = CoursePurchaseFlowType.web

    static let shared = RemoteConfig(delegate: DebugRemoteConfig.shared)

    weak var delegate: RemoteConfigDelegate?

    var loadingDoneCallback: (() -> Void)?

    private var fetchComplete = false

    private var fetchDuration: TimeInterval = 43200

    private lazy var appDefaults: [String: NSObject] = [
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
        if let stringValue = self.getStringValueFromDelegateOrRemoteConfigForKey(.showStreaksNotificationTrigger),
           let showStreaksNotificationTrigger = ShowStreaksNotificationTrigger(rawValue: stringValue) {
            return showStreaksNotificationTrigger
        }
        return Self.defaultShowStreaksNotificationTrigger
    }

    var adaptiveBackendURL: String {
        self.getStringValueFromDelegateOrRemoteConfigForKey(.adaptiveBackendUrl) ?? StepikApplicationsInfo.adaptiveRatingURL
    }

    var supportedInAdaptiveModeCourses: [Course.IdType] {
        guard let stringValue = self.getStringValueFromDelegateOrRemoteConfigForKey(.supportedInAdaptiveModeCourses) else {
            return StepikApplicationsInfo.adaptiveSupportedCourses
        }

        let courses = stringValue.components(separatedBy: ",")
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
        self.getNSStringValueFromDelegateOrRemoteConfigForKey(.arQuickLookAvailable)?.boolValue ?? false
    }

    var searchResultsQueryParams: JSONDictionary {
        if let params = self.getJSONDictionaryFromDelegateOrRemoteConfigForKey(.searchResultsQueryParams) {
            return params
        }
        return self.appDefaults[Key.searchResultsQueryParams.rawValue] as? JSONDictionary ?? [:]
    }

    var isCoursePricesEnabled: Bool {
        self.getNSStringValueFromDelegateOrRemoteConfigForKey(.isCoursePricesEnabled)?.boolValue ?? false
    }

    var isCourseRevenueAvailable: Bool {
        self.getNSStringValueFromDelegateOrRemoteConfigForKey(.isCourseRevenueAvailable)?.boolValue ?? false
    }

    var coursePurchaseFlow: CoursePurchaseFlowType {
        if let stringValue = self.getStringValueFromDelegateOrRemoteConfigForKey(.purchaseFlow),
           let coursePurchaseFlowType = CoursePurchaseFlowType(rawValue: stringValue) {
            return coursePurchaseFlowType
        }
        return Self.defaultCoursePurchaseFlowType
    }

    init(delegate: RemoteConfigDelegate? = nil) {
        self.delegate = delegate

        self.setConfigDefaults()
        self.fetchRemoteConfigData()
    }

    func setup() {}

    func value(for key: Key) -> RemoteConfigValue {
        FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(forKey: key.rawValue)
    }

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

    private func getRemoteConfigValueForKey(_ key: Key) -> RemoteConfigValue {
        FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(forKey: key.rawValue)
    }

    private func getStringValueFromDelegateOrRemoteConfigForKey(_ key: Key) -> String? {
        if let delegateValue = self.delegate?.remoteConfig(self, configValueForKey: key) as? String {
            return delegateValue
        }
        return self.getRemoteConfigValueForKey(key).stringValue
    }

    private func getNSStringValueFromDelegateOrRemoteConfigForKey(_ key: Key) -> NSString? {
        if let delegateValue = self.delegate?.remoteConfig(self, configValueForKey: key) as? NSString {
            return delegateValue
        }
        return self.getRemoteConfigValueForKey(key).stringValue as NSString?
    }

    private func getJSONDictionaryFromDelegateOrRemoteConfigForKey(_ key: Key) -> JSONDictionary? {
        if let delegateStringValue = self.delegate?.remoteConfig(self, configValueForKey: key) as? String,
           let stringData = delegateStringValue.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: stringData, options: []) as? JSONDictionary {
            return jsonObject
        }
        return self.getRemoteConfigValueForKey(key).jsonValue as? JSONDictionary
    }

    // MARK: Inner Types

    enum ShowStreaksNotificationTrigger: String {
        case loginAndSubmission = "login_and_submission"
        case submission = "submission"
    }

    enum Key: String, CaseIterable {
        case showStreaksNotificationTrigger = "show_streaks_notification_trigger"
        case adaptiveBackendUrl = "adaptive_backend_url"
        case supportedInAdaptiveModeCourses = "supported_adaptive_courses_ios"
        case arQuickLookAvailable = "is_ar_quick_look_available_ios"
        case searchResultsQueryParams = "search_query_params_ios"
        case isCoursePricesEnabled = "is_course_prices_enabled_ios"
        case isCourseRevenueAvailable = "is_course_revenue_available_ios"
        case purchaseFlow = "purchase_flow_ios"

        var valueDataType: ValueDataType {
            switch self {
            case .showStreaksNotificationTrigger:
                return .string
            case .adaptiveBackendUrl:
                return .string
            case .supportedInAdaptiveModeCourses:
                return .string
            case .arQuickLookAvailable:
                return .string
            case .searchResultsQueryParams:
                return .string
            case .isCoursePricesEnabled:
                return .string
            case .isCourseRevenueAvailable:
                return .string
            case .purchaseFlow:
                return .string
            }
        }

        fileprivate var analyticsUserPropertyKey: String {
            "\(RemoteConfig.analyticsUserPropertyKeyPrefix)\(self.rawValue)"
        }
    }

    enum ValueDataType {
        case string
        case number
        case boolean
        case json
    }
}
