//
//  AnalyticsEvents+Adaptive.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension AnalyticsEvents {
    struct AdaptiveApp {
        static let firstOpen = "adaptive_first_open"
        static let onboardingFinished = "adaptive_onboarding_finished"
        static let localNotification = "adaptive_opened_by_local_notification"
    }
}
