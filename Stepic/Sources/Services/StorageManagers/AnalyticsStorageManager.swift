import Foundation

protocol AnalyticsStorageManagerProtocol: AnyObject {
    func send(_ event: AnalyticsEvent)
    func didSend(_ event: AnalyticsEvent) -> Bool
}

final class AnalyticsStorageManager: AnalyticsStorageManagerProtocol {
    static var `default`: AnalyticsStorageManager {
        AnalyticsStorageManager(analytics: StepikAnalytics.shared, userDefaults: .standard)
    }

    private let analytics: Analytics
    private let userDefaults: UserDefaults

    init(
        analytics: Analytics,
        userDefaults: UserDefaults
    ) {
        self.analytics = analytics
        self.userDefaults = userDefaults
    }

    func send(_ event: AnalyticsEvent) {
        self.userDefaults.setValue(true, forKey: self.makeKey(for: event))
    }

    func didSend(_ event: AnalyticsEvent) -> Bool {
        self.userDefaults.bool(forKey: self.makeKey(for: event))
    }

    private func makeKey(for event: AnalyticsEvent) -> String { "AnalyticsStorageManager_\(event.name)" }
}
