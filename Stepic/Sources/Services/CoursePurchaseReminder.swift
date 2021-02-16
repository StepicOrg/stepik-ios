import Foundation
import PromiseKit

protocol CoursePurchaseReminderProtocol: AnyObject {
    func remindPurchase(_ course: CoursePlainObject)
}

extension CoursePurchaseReminderProtocol {
    func remindPurchase(_ course: Course) {
        self.remindPurchase(.init(course: course))
    }
}

final class CoursePurchaseReminder: CoursePurchaseReminderProtocol {
    private let localNotificationsService: LocalNotificationsService

    init(localNotificationsService: LocalNotificationsService) {
        self.localNotificationsService = localNotificationsService
    }

    func remindPurchase(_ course: CoursePlainObject) {
        self.localNotificationsService.removeNotifications(
            withIdentifiers: [PurchaseCourseLocalNotificationProvider(course: course).identifier]
        )

        self.getReferenceDate().map {
            PurchaseCourseLocalNotificationProvider(course: course, referenceDate: $0)
        }.then { provider in
            self.localNotificationsService
                .scheduleNotification(contentProvider: provider)
                .map { provider }
        }.done { provider in
            print(
                """
                CoursePurchaseReminder :: successfully scheduled notification for course = \(course.id), \
                fireDate = \(String(describing: provider.trigger?.nextTriggerDate))
                """
            )
        }.catch { error in
            print(
                "CoursePurchaseReminder :: failed schedule notification for course = \(course.id), error = \(error)"
            )
        }
    }

    private func getReferenceDate() -> Guarantee<Date> {
        self.getClosestNotificationDate().map { $0 ?? Date() }
    }

    private func getClosestNotificationDate() -> Guarantee<Date?> {
        self.localNotificationsService.getAllNotifications().then { pendingNotificationRequests, _ in
            let purchaseNotifications = pendingNotificationRequests.filter {
                $0.identifier.starts(with: NotificationsService.NotificationType.remindPurchaseCourse.rawValue)
            }

            let closestDate = purchaseNotifications
                .compactMap { $0.trigger?.nextTriggerDate }
                .max()

            return .value(closestDate)
        }
    }
}

extension CoursePurchaseReminder {
    static var `default`: CoursePurchaseReminder {
        CoursePurchaseReminder(localNotificationsService: LocalNotificationsService())
    }
}
