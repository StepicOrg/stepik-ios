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
    private let analytics: Analytics

    init(source: Source, analytics: Analytics = StepikAnalytics.shared) {
        self.source = source
        self.analytics = analytics
    }

    func reportDefaultAlertShown() {
        self.analytics.send(.notificationsDefaultAlertShown(source: self.source.description))
    }

    func reportDefaultAlertInteractionResult(_ result: InteractionResult) {
        self.analytics.send(
            .notificationsDefaultAlertInteracted(source: self.source.description, result: result.rawValue)
        )
    }

    func reportCustomAlertShown() {
        self.analytics.send(.notificationsCustomAlertShown(source: self.source.description))
    }

    func reportCustomAlertInteractionResult(_ result: InteractionResult) {
        self.analytics.send(
            .notificationsCustomAlertInteracted(source: self.source.description, result: result.rawValue)
        )
    }

    func reportPreferencesAlertShown() {
        self.analytics.send(.notificationsPreferencesAlertShown(source: self.source.description))
    }

    func reportPreferencesAlertInteractionResult(_ result: InteractionResult) {
        self.analytics.send(
            .notificationsPreferencesAlertInteracted(source: self.source.description, result: result.rawValue)
        )
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

    enum InteractionResult: String {
        case yes
        case no
    }
}
