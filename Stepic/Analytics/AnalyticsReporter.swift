//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Amplitude_iOS
import FirebaseAnalytics
import Foundation
import YandexMobileMetrica

final class AnalyticsReporter {
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
