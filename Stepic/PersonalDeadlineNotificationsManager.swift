//
//  PersonalDeadlineNotificationsManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

class PersonalDeadlineNotificationsManager {

    static var shared = PersonalDeadlineNotificationsManager()

    private let hoursBeforeDeadlineForNotification: [Int] = [12, 36]

    func updateDeadlineNotifications(for course: Course) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {
                requests in
                print("pending \(requests.count) requests")
                print(requests)
            })

            removeNotificationsFor(course: course)
            guard let deadlines = course.sectionDeadlines else {
                return
            }

            for deadline in deadlines {
                guard let section = course.sections.first(where: {$0.id == deadline.section}) else {
                    continue
                }
                for hoursBeforeDeadline in hoursBeforeDeadlineForNotification {
                    let fireDate = deadline.deadlineDate.addingTimeInterval(-Double(hoursBeforeDeadline) * 60 * 60) //Date().addingTimeInterval(60) //
                    scheduleNotificationWith(course: course, section: section, fireDate: fireDate, hoursBeforeDeadline: hoursBeforeDeadline)
                }
            }
        } else {
            //TODO: Add analytics on non supported deadline notifications
        }
    }

    private func notificationIdentifier(section: Int, hoursBeforeDeadline: Int) -> String {
        return "personaldeadline_section_\(section)_hours_\(hoursBeforeDeadline)"
    }

    @available(iOS 10.0, *)
    private func removeNotificationsFor(course: Course) {
        var identifiers: [String] = []
        for hours in hoursBeforeDeadlineForNotification {
            identifiers += course.sectionsArray.map {
                notificationIdentifier(section: $0, hoursBeforeDeadline: hours)
            }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    @available(iOS 10.0, *)
    private func scheduleNotificationWith(course: Course, section: Section, fireDate: Date, hoursBeforeDeadline: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(course.title)"
        content.body = "Deadline for module \(section.title) is in \(hoursBeforeDeadline) hours. Don't miss it!"
        content.sound = UNNotificationSound.default()
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier(section: section.id, hoursBeforeDeadline: hoursBeforeDeadline), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {
            error in
            if let error = error {
                print("error while registering notification \(error.localizedDescription)")
            }
        })
    }
}
