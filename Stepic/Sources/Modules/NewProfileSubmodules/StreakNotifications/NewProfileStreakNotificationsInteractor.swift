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
    func doTooltipAvailabilityCheck(request: NewProfileStreakNotifications.TooltipAvailabilityCheck.Request)
}

final class NewProfileStreakNotificationsInteractor: NewProfileStreakNotificationsInteractorProtocol {
    private let presenter: NewProfileStreakNotificationsPresenterProtocol
    private let provider: NewProfileStreakNotificationsProviderProtocol

    private let streakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol
    private let notificationsService: NotificationsService
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let tooltipStorageManager: TooltipStorageManagerProtocol
    private let analyticsUserProperties: AnalyticsUserProperties
    private let analytics: Analytics

    private var currentUserID: User.IdType?

    init(
        presenter: NewProfileStreakNotificationsPresenterProtocol,
        provider: NewProfileStreakNotificationsProviderProtocol,
        streakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol,
        notificationsService: NotificationsService,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(
            presenter: NotificationsRequestOnlySettingsAlertPresenter(context: .streak),
            analytics: .init(source: .streakControl)
        ),
        tooltipStorageManager: TooltipStorageManagerProtocol,
        analyticsUserProperties: AnalyticsUserProperties = AnalyticsUserProperties.shared,
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.presenter = presenter
        self.provider = provider

        self.streakNotificationsStorageManager = streakNotificationsStorageManager
        self.notificationsService = notificationsService
        self.notificationsRegistrationService = notificationsRegistrationService
        self.tooltipStorageManager = tooltipStorageManager
        self.analyticsUserProperties = analyticsUserProperties
        self.analytics = analytics

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPermissionStatusUpdate(_:)),
            name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onStreaksAlertPresentationManagerDidChangeStreakNotifications),
            name: .streaksAlertPresentationManagerDidChangeStreakNotifications,
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

    func doTooltipAvailabilityCheck(request: NewProfileStreakNotifications.TooltipAvailabilityCheck.Request) {
        let shouldShowTooltip = !self.tooltipStorageManager.didShowOnProfileStreakNotificationsSwitch
            && !self.streakNotificationsStorageManager.isStreakNotificationsEnabled
        self.tooltipStorageManager.didShowOnProfileStreakNotificationsSwitch = true
        self.presenter.presentTooltip(response: .init(shouldShowTooltip: shouldShowTooltip))
    }

    // MARK: Private API

    private func presentStreakNotifications(permissionStatus: NotificationPermissionStatus? = nil) {
        firstly { () -> Guarantee<NotificationPermissionStatus> in
            if let permissionStatus = permissionStatus {
                return .value(permissionStatus)
            }
            return NotificationPermissionStatus.current
        }.done { permissionStatus in
            let isOn = permissionStatus.isRegistered
                && self.streakNotificationsStorageManager.isStreakNotificationsEnabled
            let startHour = self.streakNotificationsStorageManager.streakNotificationsStartHourUTC

            self.presenter.presentStreakNotifications(
                response: .init(
                    isStreakNotificationsEnabled: isOn,
                    streaksNotificationsStartHour: startHour
                )
            )
        }
    }

    private func setStreakNotificationsEnabled(_ enabled: Bool) {
        self.analyticsUserProperties.setStreaksNotificationsEnabled(enabled)

        if enabled {
            self.streakNotificationsStorageManager.isStreakNotificationsEnabled = true
            self.notificationsRegistrationService.registerForRemoteNotifications()

            self.analytics.send(.streaksPreferenceOn)

            guard let currentUserID = self.currentUserID else {
                return
            }

            self.provider.fetchStreakLocalNotificationType(userID: currentUserID).done { streakType in
                self.notificationsService.scheduleStreakLocalNotification(
                    utcStartHour: self.streakNotificationsStorageManager.streakNotificationsStartHourUTC,
                    streakType: streakType
                )
            }
        } else {
            self.turnOffStreakNotifications()
        }
    }

    private func turnOffStreakNotifications() {
        self.notificationsService.removeStreakLocalNotifications()
        self.streakNotificationsStorageManager.isStreakNotificationsEnabled = false
        self.analytics.send(.streaksPreferenceOff)
    }

    @objc
    private func onPermissionStatusUpdate(_ notification: Foundation.Notification) {
        if let permissionStatus = notification.object as? NotificationPermissionStatus {
            self.presentStreakNotifications(permissionStatus: permissionStatus)
        }
    }

    @objc
    private func onStreaksAlertPresentationManagerDidChangeStreakNotifications() {
        self.doStreakNotificationsLoad(request: .init())
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
        self.currentUserID = user.id
        self.doStreakNotificationsLoad(request: .init())
    }
}
