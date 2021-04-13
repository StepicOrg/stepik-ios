import Foundation

final class LocalNotificationsMigrator {
    private let notificationsService: NotificationsService
    private let authInfo: AuthInfo
    private let notificationPreferencesContainer: NotificationPreferencesContainer
    private let personalDeadlinesService: PersonalDeadlinesServiceProtocol

    init(
        notificationsService: NotificationsService = NotificationsService(),
        authInfo: AuthInfo = .shared,
        notificationPreferencesContainer: NotificationPreferencesContainer = NotificationPreferencesContainer(),
        personalDeadlinesService: PersonalDeadlinesServiceProtocol = PersonalDeadlinesService()
    ) {
        self.notificationsService = notificationsService
        self.authInfo = authInfo
        self.notificationPreferencesContainer = notificationPreferencesContainer
        self.personalDeadlinesService = personalDeadlinesService
    }

    func migrateIfNeeded() {
        if self.didMigrateLocalNotifications {
            return
        }

        self.notificationsService.removeAllLocalNotifications()

        self.migrateStreakNotifications()
        self.migratePersonalDeadlinesNotifications()

        self.didMigrateLocalNotifications = true
        self.localNotificationsVersion = 2
    }

    private func migrateStreakNotifications() {
        if self.notificationPreferencesContainer.allowStreaksNotifications {
            self.notificationsService.scheduleStreakLocalNotification(
                utcStartHour: self.notificationPreferencesContainer.streaksNotificationStartHourUTC
            )
        }
    }

    private func migratePersonalDeadlinesNotifications() {
        guard let userID = self.authInfo.userId else {
            return
        }

        for course in Course.getAllCourses(enrolled: true) {
            _ = self.personalDeadlinesService.syncDeadline(for: course, userID: userID)
        }
    }
}

// MARK: - LocalNotificationsMigrator (UserDefaults) -

extension LocalNotificationsMigrator {
    private static let didMigrateLocalNotificationsKey = "didMigrateLocalNotificationsKey"
    private static let localNotificationsVersionKey = "localNotificationsVersionKey"

    private var didMigrateLocalNotifications: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.didMigrateLocalNotificationsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.didMigrateLocalNotificationsKey)
        }
    }

    private var localNotificationsVersion: Int {
        get {
            UserDefaults.standard.value(forKey: Self.localNotificationsVersionKey) as? Int ?? 1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.localNotificationsVersionKey)
        }
    }
}
