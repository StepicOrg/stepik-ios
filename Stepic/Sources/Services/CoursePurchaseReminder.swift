import Foundation
import PromiseKit

protocol CoursePurchaseReminderProtocol: AnyObject {
    func createPurchaseNotification(for course: Course)
    func removePurchaseNotification(for courseID: Course.IdType)
    func updatePurchaseNotification(for courseID: Course.IdType)
    func updateAllPurchaseNotifications()
}

final class CoursePurchaseReminder: CoursePurchaseReminderProtocol {
    private let localNotificationsService: LocalNotificationsService

    private let coursePaymentsNetworkService: CoursePaymentsNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        localNotificationsService: LocalNotificationsService,
        coursePaymentsNetworkService: CoursePaymentsNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.localNotificationsService = localNotificationsService
        self.coursePaymentsNetworkService = coursePaymentsNetworkService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func createPurchaseNotification(for course: Course) {
        let courseID = course.id
        let courseTitle = course.title

        self.removePurchaseNotification(for: courseID)

        self.getReferenceDate().map {
            PurchaseCourseLocalNotificationProvider(courseID: courseID, courseTitle: courseTitle, referenceDate: $0)
        }.then { provider in
            self.localNotificationsService
                .scheduleNotification(contentProvider: provider)
                .map { provider }
        }.done { provider in
            print(
                """
                CoursePurchaseReminder :: successfully scheduled notification for course = \(courseID), \
                fireDate = \(String(describing: provider.trigger?.nextTriggerDate))
                """
            )
        }.catch { error in
            print(
                "CoursePurchaseReminder :: failed schedule notification for course = \(courseID), error = \(error)"
            )
        }
    }

    func removePurchaseNotification(for courseID: Course.IdType) {
        self.localNotificationsService.removeNotifications(
            withIdentifiers: [PurchaseCourseLocalNotificationProvider(courseID: courseID).identifier]
        )
        print("CoursePurchaseReminder :: did remove notification for course = \(courseID)")
    }

    func updatePurchaseNotification(for courseID: Course.IdType) {
        self.getPurchaseNotificationRequest(for: courseID).then { notificationRequest -> Promise<Bool> in
            guard notificationRequest != nil else {
                return .value(false)
            }

            return self.getCoursePurchaseStatusFlag(courseID)
        }.done { isPurchased in
            if isPurchased {
                self.removePurchaseNotification(for: courseID)
            }
        }.catch { error in
            print(
                "CoursePurchaseReminder :: failed update notification for course = \(courseID), error = \(error)"
            )
        }
    }

    func updateAllPurchaseNotifications() {
        self.getAllPurchaseNotificationRequests().compactMapValues { notificationRequest in
            notificationRequest.content.userInfo[PurchaseCourseLocalNotificationProvider.Key.course.rawValue] as? Int
        }.done { courseIDs in
            courseIDs.forEach {
                self.updatePurchaseNotification(for: $0)
            }
        }
    }

    // MARK: Private API

    private func getReferenceDate() -> Guarantee<Date> {
        self.getClosestNotificationDate().map { closestDate in
            let nowDate = Date()

            if let closestDate = closestDate,
               closestDate.compare(nowDate) == .orderedDescending {
                return closestDate
            }

            return nowDate
        }
    }

    private func getClosestNotificationDate() -> Guarantee<Date?> {
        self.getAllPurchaseNotificationRequests().then { purchaseNotifications in
            let closestDate = purchaseNotifications
                .compactMap { $0.trigger?.nextTriggerDate }
                .max()

            return .value(closestDate)
        }
    }

    private func getAllPurchaseNotificationRequests() -> Guarantee<[UNNotificationRequest]> {
        self.localNotificationsService.getAllNotifications().then { pendingNotificationRequests, _ in
            let purchaseNotifications = pendingNotificationRequests.filter {
                $0.identifier.starts(with: NotificationsService.NotificationType.remindPurchaseCourse.rawValue)
            }

            return .value(purchaseNotifications)
        }
    }

    private func getPurchaseNotificationRequest(for courseID: Course.IdType) -> Guarantee<UNNotificationRequest?> {
        self.getAllPurchaseNotificationRequests().filterValues { notificationRequest in
            if let notificationCourseID = notificationRequest.content.userInfo[
                PurchaseCourseLocalNotificationProvider.Key.course.rawValue
            ] as? Int {
                return courseID == notificationCourseID
            }
            return false
        }.map { $0.first }
    }

    private func getCoursePurchaseStatusFlag(_ courseID: Course.IdType) -> Promise<Bool> {
        self.coursesPersistenceService.fetch(id: courseID).then { course -> Promise<Bool> in
            if let course = course {
                return .value(course.enrolled || course.isPurchased)
            }

            return .value(false)
        }.then { cachedPurchasesStatus -> Promise<Bool> in
            if cachedPurchasesStatus {
                return .value(true)
            }

            return self.coursePaymentsNetworkService.fetch(courseID: courseID)
                .filterValues { $0.status == .success }
                .map { !$0.isEmpty }
        }
    }
}

extension CoursePurchaseReminder {
    static var `default`: CoursePurchaseReminder {
        CoursePurchaseReminder(
            localNotificationsService: LocalNotificationsService(),
            coursePaymentsNetworkService: CoursePaymentsNetworkService(coursePaymentsAPI: CoursePaymentsAPI()),
            coursesPersistenceService: CoursesPersistenceService()
        )
    }
}
