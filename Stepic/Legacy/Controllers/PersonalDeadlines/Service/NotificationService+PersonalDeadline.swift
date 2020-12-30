//
//  NotificationsService+PersonalDeadline.swift
//  Stepic
//
//  Created by Ivan Magda on 15/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension NotificationsService {
    private static let hoursBeforePersonalDeadlineNotification = [12, 36]

    func updatePersonalDeadlineNotifications(for course: Course) {
        let contentProviders = self.getLocalNotificationContentProviders(course: course)
        for contentProvider in contentProviders {
            self.scheduleLocalNotification(with: contentProvider, removeIdentical: true)
        }
    }

    func removePersonalDeadlineNotifications(for course: Course) {
        let identifiers = self.getLocalNotificationContentProviders(course: course).map(\.identifier)
        self.removeLocalNotifications(withIdentifiers: identifiers)
    }

    private func getLocalNotificationContentProviders(
        course: Course
    ) -> [PersonalDeadlineLocalNotificationContentProvider] {
        var result = [PersonalDeadlineLocalNotificationContentProvider]()

        guard let deadlines = course.sectionDeadlines else {
            return []
        }

        for deadline in deadlines {
            guard let section = course.sections.first(where: { $0.id == deadline.section }) else {
                continue
            }

            Self.hoursBeforePersonalDeadlineNotification.forEach { hoursBeforeDeadline in
                let numberOfSeconds = Double(hoursBeforeDeadline) * 60.0 * 60.0
                let fireDate = deadline.deadlineDate.addingTimeInterval(-numberOfSeconds)
                let contentProvider = PersonalDeadlineLocalNotificationContentProvider(
                    course: course,
                    section: section,
                    deadlineDate: fireDate,
                    hoursBeforeDeadline: hoursBeforeDeadline
                )

                result.append(contentProvider)
            }
        }

        return result
    }
}
