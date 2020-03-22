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
        guard let deadlines = course.sectionDeadlines else {
            return
        }

        for deadline in deadlines {
            guard let section = course.sections.first(where: { $0.id == deadline.section }) else {
                continue
            }

            NotificationsService.hoursBeforePersonalDeadlineNotification.forEach { hoursBeforeDeadline in
                let numberOfSeconds = Double(hoursBeforeDeadline) * 60.0 * 60.0
                let fireDate = deadline.deadlineDate.addingTimeInterval(-numberOfSeconds)
                let contentProvider = PersonalDeadlineLocalNotificationContentProvider(
                    course: course,
                    section: section,
                    deadlineDate: fireDate,
                    hoursBeforeDeadline: hoursBeforeDeadline
                )

                self.scheduleLocalNotification(with: contentProvider, removeIdentical: true)
            }
        }
    }
}
