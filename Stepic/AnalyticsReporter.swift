//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import YandexMobileMetrica
import Amplitude_iOS

class AnalyticsReporter: ABAnalyticsServiceProtocol {
    func reportOnce(test: String, group: String) {
        let didReportKey = "did-report-\(test)"
        if (UserDefaults.standard.value(forKey: didReportKey) as? Bool) != true {
            AnalyticsReporter.reportAmplitudeEvent(test, parameters: ["group": group])
            UserDefaults.standard.set(true, forKey: didReportKey)
        }
    }

    static func reportEvent(_ event: String, parameters: [String: Any]? = nil) {
        let params = parameters as? [String: NSObject]

        reportFirebaseEvent(event, parameters: params)
        reportAppMetricaEvent(event, parameters: params)
    }

    static func reportAmplitudeEvent(_ event: String, parameters: [String: Any]? = nil) {
        Amplitude.instance().logEvent(event, withEventProperties: parameters)
        #if DEBUG
        print("Logging amplitude event \(event), parameters: \(String(describing: parameters))")
        #endif
    }

    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) {
        Analytics.logEvent(event, parameters: parameters)
    }

    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) {
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: nil)
    }
}
