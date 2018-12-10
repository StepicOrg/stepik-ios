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
        switch self.recurrence {
        case .nextDay:
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())
        case .thirdDay:
            return Calendar.current.date(byAdding: .day, value: 3, to: Date())
        }
    }

    var repeatInterval: NSCalendar.Unit? {
        switch self.recurrence {
        case .nextDay:
            return nil
        case .thirdDay:
            return .day
        }
    }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? {
        switch self.recurrence {
        case .nextDay:
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                let components = Calendar.current.dateComponents([.hour, .day, .month, .year], from: tomorrow)
                return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            } else {
                return nil
            }
        case .thirdDay:
            return UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: true)
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
        self.retentionNotificationProviders.forEach { provider in
            self.scheduleLocalNotification(with: provider)
        }
    }

    func removeRetentionNotifications() {
        let ids = self.retentionNotificationProviders.map { provider -> String in
            provider.identifier
        }
        self.removeLocalNotifications(withIdentifiers: ids)
    }
}
