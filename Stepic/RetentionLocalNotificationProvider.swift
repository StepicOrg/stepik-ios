//
// RetentionLocalNotificationProvider.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-12-07.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import UserNotifications

final class RetentionLocalNotificationProvider: LocalNotificationContentProvider {
    private let recurrence: Recurrence

    private var dateComponents: DateComponents? {
        let offset: Int
        switch self.recurrence {
        case .nextDay:
            offset = 1
        case .thirdDay:
            offset = 3
        }

        let components: Set<Calendar.Component> = [.hour, .day, .month, .year]
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
            return Calendar.current.dateComponents(components, from: date)
        } else {
            return nil
        }
    }

    var title: String {
        let key: String
        switch self.recurrence {
        case .nextDay:
            key = "RetentionNotificationOnNextDayTitle"
        case .thirdDay:
            key = "RetentionNotificationOnThirdDayTitle"
        }
        if #available(iOS 10.0, *) {
            return NSString.localizedUserNotificationString(forKey: key, arguments: nil)
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }

    var body: String {
        let key: String
        switch self.recurrence {
        case .nextDay:
            key = "RetentionNotificationOnNextDayText"
        case .thirdDay:
            key = "RetentionNotificationOnThirdDayText"
        }
        if #available(iOS 10.0, *) {
            return NSString.localizedUserNotificationString(forKey: key, arguments: nil)
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }

    var identifier: String {
        return "RetentionLocalNotification_\(self.recurrence.rawValue)"
    }

    var fireDate: Date? {
        if let dateComponents = self.dateComponents {
            return Calendar.current.date(from: dateComponents)
        } else {
            return nil
        }
    }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? {
        guard let dateComponents = self.dateComponents else {
            return nil
        }

        switch self.recurrence {
        case .nextDay:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .thirdDay:
            let timeInterval: TimeInterval
            if let date = Calendar.current.date(from: dateComponents) {
                timeInterval = date.timeIntervalSince(Date())
            } else {
                timeInterval = 3 * 24 * 60 * 60
            }
            return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        }
    }

    init(recurrence: Recurrence) {
        self.recurrence = recurrence
    }

    enum Recurrence: String {
        case nextDay
        case thirdDay
    }
}

extension NotificationsService {
    private var retentionNotificationProviders: [RetentionLocalNotificationProvider] {
        return [.init(recurrence: .nextDay), .init(recurrence: .thirdDay)]
    }

    func scheduleRetentionNotifications() {
        if !PreferencesContainer.notifications.allowStreaksNotifications {
            self.retentionNotificationProviders.forEach { provider in
                self.scheduleLocalNotification(with: provider)
            }
        }
    }

    func removeRetentionNotifications() {
        let ids = self.retentionNotificationProviders.map { provider in
            provider.identifier
        }
        self.removeLocalNotifications(withIdentifiers: ids)
    }
}
