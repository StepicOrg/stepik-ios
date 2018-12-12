//
//  NotificationAlertsAnalytics.swift
//  Stepic
//
//  Created by Ivan Magda on 30/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct NotificationAlertsAnalytics {
    let source: Source

    func reportDefaultAlertShown() {
        AmplitudeAnalyticsEvents.Notifications.defaultAlertShown(
            source: self.source.description
        ).send()
    }

    func reportDefaultAlertInteractionResult(
        _ result: AmplitudeAnalyticsEvents.Notifications.InteractionResult
    ) {
        AmplitudeAnalyticsEvents.Notifications.defaultAlertInteracted(
            source: self.source.description,
            result: result
        ).send()
    }

    func reportCustomAlertShown() {
        AmplitudeAnalyticsEvents.Notifications.customAlertShown(
            source: self.source.description
        ).send()
    }

    func reportCustomAlertInteractionResult(
        _ result: AmplitudeAnalyticsEvents.Notifications.InteractionResult
    ) {
        AmplitudeAnalyticsEvents.Notifications.customAlertInteracted(
            source: self.source.description,
            result: result
        ).send()
    }

    enum Source {
        case streakControl
        case notificationsTab
        case courseSubscription
        case streakAfterLogin
        case streakAfterSubmission(shownCount: Int)
        case personalDeadline
        case onboarding

        var description: String {
            switch self {
            case .streakControl:
                return "streak control"
            case .notificationsTab:
                return "notifications tab"
            case .courseSubscription:
                return "course subscription"
            case .streakAfterLogin:
                return "streak after login"
            case .streakAfterSubmission(let shownCount):
                return "streak after submission - \(shownCount)"
            case .personalDeadline:
                return "create personal deadline"
            case .onboarding:
                return "onboarding"
            }
        }
    }
}
