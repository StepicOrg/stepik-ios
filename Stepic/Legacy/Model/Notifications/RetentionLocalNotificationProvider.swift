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
    private static let defaultRetentionHour = 17
    private static let retentionHoursRange = (12...19)

    private let repetition: Repetition

    /// Represents retention date `DateComponents` between retention hours `retentionHoursRange`.
    /// - Based on `repetition` may contain:
    ///     - next day date
    ///     - third day date
    /// See `Repetition` for existing recurrences.
    private var dateComponents: DateComponents? {
        let components: Set<Calendar.Component> = [.hour, .day, .month, .year]
        let dayOffset = self.repetition.notificationDayOffset
        if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
            var retentionDateComponents = Calendar.current.dateComponents(components, from: date)
            var retentionHour = retentionDateComponents.hour ?? RetentionLocalNotificationProvider.defaultRetentionHour

            if !RetentionLocalNotificationProvider.retentionHoursRange.contains(retentionHour) {
                retentionHour = RetentionLocalNotificationProvider.defaultRetentionHour
            }

            retentionDateComponents.hour = retentionHour

            return retentionDateComponents
        } else {
            return nil
        }
    }

    var title: String { self.repetition.notificationTitle }

    var body: String { self.repetition.notificationText }

    var userInfo: [AnyHashable: Any] {
        [
            NotificationsService.PayloadKey.type.rawValue: self.repetition.notificationType
        ]
    }

    var identifier: String { "RetentionLocalNotification_\(self.repetition.rawValue)" }

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
            NSString.localizedUserNotificationString(forKey: key, arguments: nil)
        }
    }
}

extension NotificationsService {
    private var retentionNotificationProviders: [RetentionLocalNotificationProvider] {
        [
            .init(repetition: .nextDay),
            .init(repetition: .thirdDay)
        ]
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
