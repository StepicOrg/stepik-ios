//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

#if os(iOS)
    import Firebase
    import Mixpanel
    import YandexMobileMetrica
#endif

class AnalyticsReporter {
    
    static func reportEvent(_ event: String, parameters: [String: NSObject]?) {
        #if os(iOS)
            reportFirebaseEvent(event, parameters: parameters)
            reportAppMetricaEvent(event, parameters: parameters)
            reportMixpanelEvent(event, parameters: parameters)
        #endif
    }
    
    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) {
        #if os(iOS)
            FIRAnalytics.logEvent(withName: event, parameters: parameters)
        #endif
    }
    
    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) {
        #if os(iOS)
            YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: nil)
        #endif
    }
    
    static func reportMixpanelEvent(_ event: String, parameters: [String: NSObject]?) {
        #if os(iOS)
            var transformedParameters : Properties = [:]
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
