import Amplitude_iOS
import FirebaseAnalytics
import Foundation
import YandexMobileMetrica

final class AnalyticsReporter {
    private init() { }

    static func reportEvent(_ event: String, parameters: [String: Any]? = nil) {
        let params = parameters as? [String: NSObject]

        self.reportFirebaseEvent(event, parameters: params)
        self.reportAppMetricaEvent(event, parameters: params)
    }

    static func reportAmplitudeEvent(_ event: String, parameters: [String: Any]? = nil) {
        Amplitude.instance().logEvent(event, withEventProperties: parameters)
        #if DEBUG
        print("Logging amplitude event \(event), parameters: \(String(describing: parameters))")
        #endif
    }

    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) {
        Analytics.logEvent(event, parameters: parameters)
        #if DEBUG
        print("Logging Firebase event \(event), parameters: \(String(describing: parameters))")
        #endif
    }

    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) {
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: nil)
        #if DEBUG
        print("Logging AppMetrica event \(event), parameters: \(String(describing: parameters))")
        #endif
    }
}
