import Amplitude_iOS
import FirebaseAnalytics
import Foundation
import YandexMobileMetrica

protocol AnalyticsEngine: AnyObject {
    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?)
}

extension AnalyticsEngine {
    func sendAnalyticsEvent(named name: String) {
        self.sendAnalyticsEvent(named: name, parameters: nil)
    }
}

final class AmplitudeAnalyticsEngine: AnalyticsEngine {
    private let instance: Amplitude

    init(instance: Amplitude = Amplitude.instance()) {
        self.instance = instance
    }

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        self.instance.logEvent(name, withEventProperties: parameters)
        print("Logging Amplitude event: \(name), parameters: \(String(describing: parameters)))")
    }
}

final class FirebaseAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        FirebaseAnalytics.Analytics.logEvent(name, parameters: parameters)
        print("Logging Firebase event: \(name), parameters: \(String(describing: parameters))")
    }
}

final class AppMetricaAnalyticsEngine: AnalyticsEngine {
    init() {}

    func sendAnalyticsEvent(named name: String, parameters: [String: Any]?) {
        YMMYandexMetrica.reportEvent(name, parameters: parameters)
        print("Logging AppMetrica event: \(name), parameters: \(String(describing: parameters))")
    }
}
