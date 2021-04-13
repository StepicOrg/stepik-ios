import Foundation
import UserNotifications

struct PersonalDeadlineLocalNotification: LocalNotificationProtocol {
    let course: Course
    let section: Section
    let deadlineDate: Date
    let hoursBeforeDeadline: Int

    var title: String { "\(self.course.title)" }

    var body: String {
        NSString.localizedUserNotificationString(
            forKey: "PersonalDeadlineNotificationBody",
            arguments: ["\(self.section.title)", "\(self.hoursBeforeDeadline)"]
        )
    }

    var userInfo: [AnyHashable: Any] {
        [
            UserInfoKey.course.rawValue: self.course.id,
            UserInfoKey.section.rawValue: self.section.id,
            UserInfoKey.hoursBeforeDeadline.rawValue: self.hoursBeforeDeadline,
            NotificationsService.PayloadKey.type.rawValue: NotificationsService.NotificationType.personalDeadline.rawValue
        ]
    }

    var identifier: String {
        "\(NotificationsService.NotificationType.personalDeadline.rawValue)_section_\(self.section.id)_hours_\(self.hoursBeforeDeadline)"
    }

    var trigger: UNNotificationTrigger? {
        UNCalendarNotificationTrigger(dateMatching: self.dateComponents, repeats: false)
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

    enum UserInfoKey: String {
        case course
        case section
        case hoursBeforeDeadline
    }
}

// MARK: - NotificationsService (PersonalDeadlineLocalNotification) -

extension NotificationsService {
    private static let hoursBeforePersonalDeadlineNotification = [12, 36]

    func updatePersonalDeadlineLocalNotifications(course: Course) {
        let notifications = self.getPersonalDeadlineLocalNotifications(course: course)
        notifications.forEach { notification in
            self.scheduleLocalNotification(notification)
        }
    }

    func removePersonalDeadlineLocalNotifications(course: Course) {
        let identifiers = self.getPersonalDeadlineLocalNotifications(course: course).map(\.identifier)
        self.removeLocalNotifications(withIdentifiers: identifiers)
    }

    private func getPersonalDeadlineLocalNotifications(course: Course) -> [PersonalDeadlineLocalNotification] {
        var result = [PersonalDeadlineLocalNotification]()

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
                let notification = PersonalDeadlineLocalNotification(
                    course: course,
                    section: section,
                    deadlineDate: fireDate,
                    hoursBeforeDeadline: hoursBeforeDeadline
                )

                result.append(notification)
            }
        }

        return result
    }
}
