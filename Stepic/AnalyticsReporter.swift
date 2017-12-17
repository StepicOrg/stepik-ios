//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Firebase
import Mixpanel
import YandexMobileMetrica

class AnalyticsReporter {
    static func reportEvent(_ event: String, parameters: [String: Any]? = nil) {
            let params = parameters as? [String: NSObject]

            reportFirebaseEvent(event, parameters: params)
            reportAppMetricaEvent(event, parameters: params)
            reportMixpanelEvent(event, parameters: parameters)
    }

    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) {
        FIRAnalytics.logEvent(withName: event, parameters: parameters)
    }

    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) {
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: nil)
    }

    static func reportMixpanelEvent(_ event: String, parameters: [String: Any]?) {
        var transformedParameters: Properties = [:]
        if let p = parameters {
            for (key, value) in p {
                if let v = value as? MixpanelType {
                    transformedParameters[key] = v
                }
            }
        }
        Mixpanel.mainInstance().track(event: event, properties: transformedParameters)
    }
}
