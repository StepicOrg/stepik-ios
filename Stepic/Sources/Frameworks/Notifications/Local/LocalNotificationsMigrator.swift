import Foundation

final class LocalNotificationsMigrator {
    private let notificationsService: NotificationsService
    private let userAccountService: UserAccountServiceProtocol
    private let notificationPreferencesContainer: NotificationPreferencesContainer
    private let personalDeadlinesService: PersonalDeadlinesServiceProtocol
    private let profileStreakNotificationsProvider: NewProfileStreakNotificationsProviderProtocol

    init(
        notificationsService: NotificationsService = NotificationsService(),
        userAccountService: UserAccountServiceProtocol = UserAccountService(),
        notificationPreferencesContainer: NotificationPreferencesContainer = NotificationPreferencesContainer(),
        personalDeadlinesService: PersonalDeadlinesServiceProtocol = PersonalDeadlinesService(),
        // swiftlint:disable:next line_length
        profileStreakNotificationsProvider: NewProfileStreakNotificationsProviderProtocol = NewProfileStreakNotificationsProvider(
            submissionsPersistenceService: SubmissionsPersistenceService(),
            userActivitiesPersistenceService: UserActivitiesPersistenceService()
        )
    ) {
        self.notificationsService = notificationsService
        self.userAccountService = userAccountService
        self.notificationPreferencesContainer = notificationPreferencesContainer
        self.personalDeadlinesService = personalDeadlinesService
        self.profileStreakNotificationsProvider = profileStreakNotificationsProvider
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
        guard self.notificationPreferencesContainer.allowStreaksNotifications,
              let currentUserID = self.userAccountService.currentUserID else {
            return
        }

        self.profileStreakNotificationsProvider.fetchStreakLocalNotificationType(
            userID: currentUserID
        ).done { streakType in
            self.notificationsService.scheduleStreakLocalNotification(
                utcStartHour: self.notificationPreferencesContainer.streaksNotificationStartHourUTC,
                streakType: streakType
            )
        }
    }

    private func migratePersonalDeadlinesNotifications() {
        guard let currentUserID = self.userAccountService.currentUserID else {
            return
        }

        for course in Course.getAllCourses(enrolled: true) {
            _ = self.personalDeadlinesService.syncDeadline(for: course, userID: currentUserID)
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
