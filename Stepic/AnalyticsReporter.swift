//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

#if !os(tvOS)
import Firebase
import Mixpanel
import YandexMobileMetrica
#endif

class AnalyticsReporter {
    static func reportEvent(_ event: String, parameters: [String: Any]? = nil) {
        #if !os(tvOS)
        let params = parameters as? [String: NSObject]

        reportFirebaseEvent(event, parameters: params)
        reportAppMetricaEvent(event, parameters: params)
        reportMixpanelEvent(event, parameters: parameters)
        #endif
    }

    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) {
        #if !os(tvOS)
        FIRAnalytics.logEvent(withName: event, parameters: parameters)
        #endif
    }

    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) {
        #if !os(tvOS)
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: nil)
        #endif
    }

    static func reportMixpanelEvent(_ event: String, parameters: [String: Any]?) {
        #if !os(tvOS)
        var transformedParameters: Properties = [:]
        if let p = parameters {
            for (key, value) in p {
                if let v = value as? MixpanelType {
                    transformedParameters[key] = v
                }
            }
        }
        Mixpanel.mainInstance().track(event: event, properties: transformedParameters)
        #endif
    }
}
