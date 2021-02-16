import Foundation
import UserNotifications

final class PurchaseCourseLocalNotificationProvider: LocalNotificationContentProvider {
    private static let hourDelay = 1
    private static let defaultFireHour = 12

    private let course: CoursePlainObject
    private let referenceDate: Date

    private var dateComponents: DateComponents? {
        guard let fireDate = Calendar.current.date(byAdding: .hour, value: Self.hourDelay, to: self.referenceDate) else {
            return nil
        }

        let components: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year]
        var dateComponents = Calendar.current.dateComponents(components, from: fireDate)

        switch dateComponents.hour ?? Self.defaultFireHour {
        case let fireHour where fireHour < 12:
            dateComponents.hour = Self.defaultFireHour
        case let fireHour where fireHour >= 21:
            if let adjustedDate = Calendar.current.date(byAdding: .day, value: 1, to: fireDate) {
                dateComponents = Calendar.current.dateComponents(components, from: adjustedDate)
            }
        default:
            break
        }

        return dateComponents
    }

    var title: String {
        NSString.localizedUserNotificationString(forKey: "PurchaseCourseNotificationTitle", arguments: nil)
    }

    var body: String {
        NSString.localizedUserNotificationString(
            forKey: "PurchaseCourseNotificationText",
            arguments: [self.course.title]
        )
    }

    var userInfo: [AnyHashable: Any] {
        [
            Key.course.rawValue: self.course.id,
            NotificationsService.PayloadKey.type.rawValue: NotificationsService.NotificationType.remindPurchaseCourse.rawValue
        ]
    }

    var identifier: String {
        "\(NotificationsService.NotificationType.remindPurchaseCourse.rawValue)_course_\(self.course.id)"
    }

    var trigger: UNNotificationTrigger? {
        guard let dateComponents = self.dateComponents else {
            return nil
        }

        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    }

    init(course: CoursePlainObject, referenceDate: Date = Date()) {
        self.course = course
        self.referenceDate = referenceDate
    }

    enum Key: String {
        case course
    }
}
