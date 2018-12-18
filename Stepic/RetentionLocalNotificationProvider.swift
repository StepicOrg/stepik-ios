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
    private let repetition: Repetition

    /// Represents retention date `DateComponents`.
    /// - Based on `repetition` may contain:
    ///     - next day date
    ///     - third day date
    /// See `Repetition` for existing recurrences.
    private var dateComponents: DateComponents? {
        let components: Set<Calendar.Component> = [.hour, .day, .month, .year]
        let dayOffset = self.repetition.notificationDayOffset
        if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
            return Calendar.current.dateComponents(components, from: date)
        } else {
            return nil
        }
    }

    var title: String {
        return self.repetition.notificationTitle
    }

    var body: String {
        return self.repetition.notificationText
    }

    var userInfo: [AnyHashable: Any] {
        return [
            NotificationsService.PayloadKey.type.rawValue: self.repetition.notificationType
        ]
    }

    var identifier: String {
        return "RetentionLocalNotification_\(self.repetition.rawValue)"
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

        switch self.repetition {
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

    init(repetition: Repetition) {
        self.repetition = repetition
    }

    enum Repetition: String {
        case nextDay
        case thirdDay

        var notificationType: String {
            switch self {
            case .nextDay:
                return NotificationsService.NotificationType.retentionNextDay.rawValue
            case .thirdDay:
                return NotificationsService.NotificationType.retentionThirdDay.rawValue
            }
        }

        var notificationTitle: String {
            switch self {
            case .nextDay:
                return self.localized(for: "RetentionNotificationOnNextDayTitle")
            case .thirdDay:
                return self.localized(for: "RetentionNotificationOnThirdDayTitle")
            }
        }

        var notificationText: String {
            switch self {
            case .nextDay:
                return self.localized(for: "RetentionNotificationOnNextDayText")
            case .thirdDay:
                return self.localized(for: "RetentionNotificationOnThirdDayText")
            }
        }

        var notificationDayOffset: Int {
            switch self {
            case .nextDay:
                return 1
            case .thirdDay:
                return 3
            }
        }

        private func localized(for key: String) -> String {
            if #available(iOS 10.0, *) {
                return NSString.localizedUserNotificationString(forKey: key, arguments: nil)
            } else {
                return NSLocalizedString(key, comment: "")
            }
        }
    }
}

extension NotificationsService {
    private var retentionNotificationProviders: [RetentionLocalNotificationProvider] {
        return [.init(repetition: .nextDay), .init(repetition: .thirdDay)]
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
