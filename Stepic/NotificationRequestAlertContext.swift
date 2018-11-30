//
//  NotificationsS.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum NotificationRequestAlertContext: String {
    case streak = "streak"
    case notificationsTab = "notifications_tab"
    case courseSubscription = "course_subscription"
    case `default`

    var title: String {
        switch self {
        case .streak:
            return NSLocalizedString("StreakAlertTitle", comment: "")
        case .notificationsTab:
            return NSLocalizedString("NotificationTabNotificationRequestAlertTitle", comment: "")
        case .courseSubscription:
            return NSLocalizedString("CourseSubscriptionNotificationRequestAlertTitle", comment: "")
        case .default:
            return NSLocalizedString("NotificationRequestDefaultAlertTitle", comment: "")
        }
    }

    func message(streak: Int? = nil) -> String {
        switch self {
        case .streak:
            guard let streak = streak else {
                return ""
            }
            if streak > 0 {
                return String(format: NSLocalizedString("StreakAlertMessage", comment: ""), "\(streak)", pluralizedDays(count: streak))
            } else {
                return NSLocalizedString("StreakAlertMessageNoStreak", comment: "")
            }

        case .notificationsTab:
            return NSLocalizedString("NotificationTabNotificationRequestAlertMessage", comment: "")
        case .courseSubscription:
            return NSLocalizedString("CourseSubscriptionNotificationRequestAlertMessage", comment: "")
        case .default:
            return NSLocalizedString("NotificationRequestDefaultAlertMessage", comment: "")
        }
    }

    private func pluralizedDays(count: Int) -> String {
        return StringHelper.pluralize(number: count, forms: [NSLocalizedString("days1", comment: ""), NSLocalizedString("days234", comment: ""), NSLocalizedString("days567890", comment: "")])
    }
}
