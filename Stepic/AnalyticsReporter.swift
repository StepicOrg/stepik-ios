//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Firebase
import YandexMobileMetrica

class AnalyticsReporter {
    static func reportEvent(_ event: String, parameters: [String: NSObject]?) {
        reportFirebaseEvent(event, parameters: parameters)
        reportAppMetricaEvent(event, parameters: parameters)
    }
    
    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) {
        FIRAnalytics.logEvent(withName: event, parameters: parameters)
    }
    
    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) {
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: nil)
    }
}
