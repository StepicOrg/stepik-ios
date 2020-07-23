import Foundation
import PromiseKit

protocol NewProfileStreakNotificationsInteractorProtocol {
    func doStreakNotificationsLoad(request: NewProfileStreakNotifications.StreakNotificationsLoad.Request)
    func doStreakNotificationsPreferenceUpdate(
        request: NewProfileStreakNotifications.StreakNotificationsPreferenceUpdate.Request
    )
    func doSelectStreakNotificationsTimePresentation(
        request: NewProfileStreakNotifications.SelectStreakNotificationsTimePresentation.Request
    )
}

final class NewProfileStreakNotificationsInteractor: NewProfileStreakNotificationsInteractorProtocol {
    private let presenter: NewProfileStreakNotificationsPresenterProtocol
    private let streakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol
    private let notificationsService: NotificationsService
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let analyticsUserProperties: AnalyticsUserProperties
    private let analytics: Analytics

    init(
        presenter: NewProfileStreakNotificationsPresenterProtocol,
        streakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol,
        notificationsService: NotificationsService,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(
            presenter: NotificationsRequestOnlySettingsAlertPresenter(context: .streak),
            analytics: .init(source: .streakControl)
        ),
        analyticsUserProperties: AnalyticsUserProperties = AnalyticsUserProperties.shared,
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.presenter = presenter
        self.streakNotificationsStorageManager = streakNotificationsStorageManager
        self.notificationsService = notificationsService
        self.notificationsRegistrationService = notificationsRegistrationService
        self.analyticsUserProperties = analyticsUserProperties
        self.analytics = analytics

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPermissionStatusUpdate(_:)),
            name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
            object: nil
        )

        self.checkPermissionStatus()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func doStreakNotificationsLoad(request: NewProfileStreakNotifications.StreakNotificationsLoad.Request) {
        DispatchQueue.main.async {
            self.presentStreakNotifications()
        }
    }

    func doStreakNotificationsPreferenceUpdate(
        request: NewProfileStreakNotifications.StreakNotificationsPreferenceUpdate.Request
    ) {
        DispatchQueue.main.async {
            self.setStreakNotificationsEnabled(request.isOn)
            self.presentStreakNotifications()
        }
    }

    func doSelectStreakNotificationsTimePresentation(
        request: NewProfileStreakNotifications.SelectStreakNotificationsTimePresentation.Request
    ) {
        let startHour = self.streakNotificationsStorageManager.streakNotificationsStartHourLocal
        self.presenter.presentSelectStreakNotificationsTime(response: .init(startHour: startHour))
    }

    // MARK: Private API

    private func presentStreakNotifications(isStreakNotificationsEnabled: Bool? = nil) {
        let isOn = isStreakNotificationsEnabled ?? self.streakNotificationsStorageManager.isStreakNotificationsEnabled
        self.presenter.presentStreakNotifications(
            response: .init(
                isStreakNotificationsEnabled: isOn,
                streaksNotificationsStartHour: self.streakNotificationsStorageManager.streakNotificationsStartHourUTC
            )
        )
    }

    private func setStreakNotificationsEnabled(_ enabled: Bool) {
        self.analyticsUserProperties.setStreaksNotificationsEnabled(enabled)

        if enabled {
            self.streakNotificationsStorageManager.isStreakNotificationsEnabled = true
            self.notificationsRegistrationService.registerForRemoteNotifications()

            self.notificationsService.scheduleStreakLocalNotification(
                UTCStartHour: self.streakNotificationsStorageManager.streakNotificationsStartHourUTC,
                cancelPrevious: true
            )

            self.analytics.send(.streaksPreferenceOn)
        } else {
            self.turnOffStreakNotifications()
        }
    }

    private func turnOffStreakNotifications() {
        self.notificationsService.cancelStreakLocalNotifications()
        self.streakNotificationsStorageManager.isStreakNotificationsEnabled = false
        self.analytics.send(.streaksPreferenceOff)
    }

    @objc
    private func onPermissionStatusUpdate(_ notification: Foundation.Notification) {
        guard let permissionStatus = notification.object as? NotificationPermissionStatus else {
            return
        }

        let isOn = self.streakNotificationsStorageManager.isStreakNotificationsEnabled && permissionStatus.isRegistered
        self.presentStreakNotifications(isStreakNotificationsEnabled: isOn)
    }

    private func checkPermissionStatus() {
        NotificationPermissionStatus.current.done { permissionStatus in
            if self.streakNotificationsStorageManager.isStreakNotificationsEnabled && !permissionStatus.isRegistered {
                self.turnOffStreakNotifications()
                self.doStreakNotificationsLoad(request: .init())
            }
        }
    }
}

extension NewProfileStreakNotificationsInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        self.doStreakNotificationsLoad(request: .init())
    }
}
