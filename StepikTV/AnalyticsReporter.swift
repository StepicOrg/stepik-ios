//
//  AnalyticsReporter.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class AnalyticsReporter {
    static func reportEvent(_ event: String, parameters: [String: Any]? = nil) { }

    private static func reportFirebaseEvent(_ event: String, parameters: [String: NSObject]?) { }

    private static func reportAppMetricaEvent(_ event: String, parameters: [String: NSObject]?) { }

    static func reportMixpanelEvent(_ event: String, parameters: [String: Any]?) { }
}
