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
            Keys.course.rawValue: course.id,
            Keys.section.rawValue: section.id,
            Keys.hoursBeforeDeadline.rawValue: self.hoursBeforeDeadline,
            NotificationsService.Keys.type.rawValue: NotificationsService.NotificationTypes.personalDeadline.rawValue
        ]
    }

    var identifier: String {
        return "\(NotificationsService.NotificationTypes.personalDeadline.rawValue)_section_\(self.section.id)_hours_\(self.hoursBeforeDeadline)"
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

    private let course: Course
    private let section: Section
    private let deadlineDate: Date
    private let hoursBeforeDeadline: Int

    init(course: Course, section: Section, deadlineDate: Date, hoursBeforeDeadline: Int) {
        self.course = course
        self.section = section
        self.deadlineDate = deadlineDate
        self.hoursBeforeDeadline = hoursBeforeDeadline
    }

    enum Keys: String {
        case course
        case section
        case hoursBeforeDeadline
    }
}
