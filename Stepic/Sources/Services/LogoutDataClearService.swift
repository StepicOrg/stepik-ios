import Foundation
import PromiseKit

protocol LogoutDataClearServiceProtocol: AnyObject {
    func clearCurrentUserData() -> Guarantee<Void>
}

final class LogoutDataClearService: LogoutDataClearServiceProtocol {
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let notificationsService: NotificationsService
    private let spotlightIndexingService: SpotlightIndexingServiceProtocol
    private let analyticsUserProperties: AnalyticsUserProperties
    private let notificationsBadgesManager: NotificationsBadgesManager
    private let coreDataHelper: CoreDataHelper
    private let deviceDefaults: DeviceDefaults

    private let synchronizationQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.LogoutCleanerQueue",
        qos: .userInitiated
    )
    private let semaphore = DispatchSemaphore(value: 1)

    init(
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(),
        notificationsService: NotificationsService = NotificationsService(),
        spotlightIndexingService: SpotlightIndexingServiceProtocol = SpotlightIndexingService.shared,
        analyticsUserProperties: AnalyticsUserProperties = .shared,
        notificationsBadgesManager: NotificationsBadgesManager = .shared,
        coreDataHelper: CoreDataHelper = .shared,
        deviceDefaults: DeviceDefaults = .sharedDefaults
    ) {
        self.notificationsRegistrationService = notificationsRegistrationService
        self.notificationsService = notificationsService
        self.spotlightIndexingService = spotlightIndexingService
        self.analyticsUserProperties = analyticsUserProperties
        self.notificationsBadgesManager = notificationsBadgesManager
        self.coreDataHelper = coreDataHelper
        self.deviceDefaults = deviceDefaults
    }

    func clearCurrentUserData() -> Guarantee<Void> {
        Guarantee { seal in
            self.synchronizationQueue.async { [weak self] in
                guard let strongSelf = self else {
                    return seal(())
                }

                strongSelf.semaphore.wait()
                DispatchQueue.main.async {
                    strongSelf.clearData().done {
                        seal(())
                        strongSelf.semaphore.signal()
                    }
                }
            }
        }
    }

    private func clearData() -> Guarantee<Void> {
        self.notificationsRegistrationService.unregisterForRemoteNotifications().done {
            self.clearDatabase()

            self.analyticsUserProperties.clearUserDependentProperties()
            self.notificationsBadgesManager.set(number: 0)

            self.deviceDefaults.deviceId = nil

            self.notificationsService.removeAllLocalNotifications()
            self.spotlightIndexingService.deleteAllSearchableItems()
        }
    }

    private func clearDatabase() {
        // Delete enrolled information
        let enrolledCourses = Course.getAllCourses(enrolled: true)
        for course in enrolledCourses {
            course.enrolled = false
        }

        Certificate.deleteAll()
        Progress.deleteAllStoredProgresses()
        Notification.deleteAll()

        self.coreDataHelper.save()
    }
}
