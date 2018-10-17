//
//  PersonalDeadlineLocalNotificationContentProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 15/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

final class PersonalDeadlineLocalNotificationContentProvider: LocalNotificationContentProvider {
    private let course: Course
    private let section: Section
    private let deadlineDate: Date
    private let hoursBeforeDeadline: Int

    var title: String {
        return "\(self.course.title)"
    }

    var body: String {
        if #available(iOS 10.0, *) {
            return NSString.localizedUserNotificationString(
                forKey: "PersonalDeadlineNotificationBody",
                arguments: ["\(self.section.title)", "\(self.hoursBeforeDeadline)"]
            )
        } else {
            return String(
                format: NSLocalizedString("PersonalDeadlineNotificationBody", comment: ""),
                "\(self.section.title)", "\(self.hoursBeforeDeadline)"
            )
        }
    }

    var userInfo: [AnyHashable : Any] {
        return [
            Key.course.rawValue: course.id,
            Key.section.rawValue: section.id,
            Key.hoursBeforeDeadline.rawValue: self.hoursBeforeDeadline,
            NotificationsService.Key.type.rawValue: NotificationsService.NotificationType.personalDeadline.rawValue
        ]
    }

    var identifier: String {
        return "\(NotificationsService.NotificationType.personalDeadline.rawValue)_section_\(self.section.id)_hours_\(self.hoursBeforeDeadline)"
    }

    var fireDate: Date? {
        return Calendar.current.date(from: self.dateComponents)
    }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? {
        return UNCalendarNotificationTrigger(dateMatching: self.dateComponents, repeats: false)
    }

    private var dateComponents: DateComponents {
        let timeZone = TimeZone(identifier: "UTC") ?? .current

        let donorComponents = Calendar.current.dateComponents(
            in: timeZone,
            from: self.deadlineDate
        )
        let components = DateComponents(
            calendar: Calendar.current,
            timeZone: timeZone,
            year: donorComponents.year,
            month: donorComponents.month,
            day: donorComponents.day,
            hour: donorComponents.hour,
            minute: donorComponents.minute,
            second: 0
        )

        return components
    }

    init(course: Course, section: Section, deadlineDate: Date, hoursBeforeDeadline: Int) {
        self.course = course
        self.section = section
        self.deadlineDate = deadlineDate
        self.hoursBeforeDeadline = hoursBeforeDeadline
    }

    enum Key: String {
        case course
        case section
        case hoursBeforeDeadline
    }
}
