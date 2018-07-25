//
//  AnalyticsEvent.swift
//  Stepic
//
//  Created by Ostrenkiy on 17.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AnalyticsReportable {
    func send()
}

class AnalyticsEvent: AnalyticsReportable {
    func send() {
        AnalyticsReporter.reportAmplitudeEvent(name, parameters: parameters)
    }

    var name: String
    var parameters: [String: Any]?

    init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}
