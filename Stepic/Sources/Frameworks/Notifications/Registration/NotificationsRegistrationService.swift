import FirebaseCore
import FirebaseMessaging
import Foundation
import PromiseKit
import UserNotifications

final class NotificationsRegistrationService: NotificationsRegistrationServiceProtocol {
    weak var delegate: NotificationsRegistrationServiceDelegate?
    var presenter: NotificationsRegistrationPresentationServiceProtocol?
    private let analytics: NotificationAlertsAnalytics?

    init(
        delegate: NotificationsRegistrationServiceDelegate? = nil,
        presenter: NotificationsRegistrationPresentationServiceProtocol? = nil,
        analytics: NotificationAlertsAnalytics? = nil
    ) {
        self.delegate = delegate
        self.presenter = presenter
        self.analytics = analytics
    }

    // MARK: - Handling APNs pipeline events -

    func handleDeviceToken(_ deviceToken: Data) {
        print("NotificationsRegistrationService: did register for remote notifications")
        self.setAPNsTokenToFirebaseMessaging(apnsToken: deviceToken)
        self.postCurrentPermissionStatus()
        self.delegate?.notificationsRegistrationServiceDidSuccessfullyRegisterWithAPNs(self)
    }

    func handleRegistrationError(_ error: Error) {
        print("NotificationsRegistrationService: did fail register with error: \(error)")
        self.postCurrentPermissionStatus()
        self.delegate?.notificationsRegistrationServiceDidFailRegisterWithAPNs(self, error: error)
    }

    // MARK: - Register -

    func renewDeviceToken() {
        self.register(forceToRequestAuthorization: false)
    }

    func registerForRemoteNotifications() {
        self.register(forceToRequestAuthorization: true)
    }

    /// Initiates the registration pipeline.
    ///
    /// - Parameter forceToRequestAuthorization: The flag that indicates whether to request notifications
    /// permission directly or only if already has granted permissions.
    ///
    /// If the `forceToRequestAuthorization` parameter is `true` then the user will be prompted for
    /// notifications permissions directly otherwise firstly will check if has granted permissions.
    private func register(forceToRequestAuthorization: Bool) {
        self.postCurrentPermissionStatus()

        if forceToRequestAuthorization {
            self.register()
        } else {
            self.registerIfAuthorized()
        }
    }

    private func registerIfAuthorized() {
        NotificationPermissionStatus.current.done { status in
            if status.isRegistered {
                self.register()
            }
        }
    }

    private func register() {
        defer {
            self.fetchFirebaseMessagingRegistrationToken()
        }

        guard StepikApplicationsInfo.shouldRegisterNotifications else {
            return
        }

        NotificationPermissionStatus.current.done { status in
            if status == .denied {
                self.presentSettingsAlertIfNeeded()
            } else {
                self.presentPermissionAlertIfNeeded()
            }
        }
    }

    /// Prompts the user to authorize with desired notifications settings.
    private func requestAuthorization() {
        if !self.didShowDefaultPermissionAlert {
            self.analytics?.reportDefaultAlertShown()
            self.isFirstRegistrationIsInProgress = true
        }

        self.didShowDefaultPermissionAlert = true

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { granted, error in
                if self.isFirstRegistrationIsInProgress {
                    self.isFirstRegistrationIsInProgress = false
                    self.analytics?.reportDefaultAlertInteractionResult(granted ? .yes : .no)
                }

                if granted {
                    self.registerWithAPNs()
                } else if let error = error {
                    print("NotificationsRegistrationService: did fail request authorization with error: \(error)")
                }

                self.updatePushPermissionStatusUserProperty()
            }
        )
    }

    /// Initiates the registration process with Apple Push Notification service.
    private func registerWithAPNs() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    private func updatePushPermissionStatusUserProperty() {
        NotificationPermissionStatus.current.done { permissionStatus in
            AnalyticsUserProperties.shared.setPushPermissionStatus(permissionStatus)
        }
    }

    private func presentPermissionAlertIfNeeded() {
        if let delegate = self.delegate {
            if delegate.notificationsRegistrationService(self, shouldPresentAlertFor: .permission) {
                self.presentPermissionAlert()
            }
        } else {
            self.requestAuthorization()
        }
    }

    private func presentPermissionAlert() {
        self.presenter?.onPositiveCallback = {
            self.analytics?.reportCustomAlertInteractionResult(.yes)
            NotificationPermissionStatus.current.done { status in
                if status == .denied {
                    self.presentSettingsAlert()
                } else {
                    self.requestAuthorization()
                }
            }
        }
        self.presenter?.onCancelCallback = {
            self.analytics?.reportCustomAlertInteractionResult(.no)
        }

        self.analytics?.reportCustomAlertShown()
        self.presentAlert(for: .permission)
    }

    private func presentSettingsAlertIfNeeded() {
        if let delegate = self.delegate {
            if delegate.notificationsRegistrationService(self, shouldPresentAlertFor: .settings) {
                self.presentSettingsAlert()
            }
        } else {
            self.presentSettingsAlert()
        }
    }

    private func presentSettingsAlert() {
        self.presenter?.onPositiveCallback = {
            self.analytics?.reportPreferencesAlertInteractionResult(.yes)

            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsURL) {
                NotificationCenter.default.post(name: .notificationsRegistrationServiceWillOpenSettings, object: nil)
                UIApplication.shared.open(settingsURL)
            }
        }
        self.presenter?.onCancelCallback = {
            self.analytics?.reportPreferencesAlertInteractionResult(.no)
        }

        self.analytics?.reportPreferencesAlertShown()
        self.presentAlert(for: .settings)
    }

    private func presentAlert(for type: NotificationsRegistrationServiceAlertType) {
        guard let rootViewController = SourcelessRouter().window?.rootViewController else {
            return
        }

        DispatchQueue.main.async {
            self.presenter?.presentAlert(for: type, inController: rootViewController)
            self.delegate?.notificationsRegistrationService(self, didPresentAlertFor: type)
        }
    }

    // MARK: Device

    func registerDevice(_ registrationToken: String, forceCreation: Bool) {
        let newDevice = Device(
            registrationId: registrationToken,
            deviceDescription: DeviceInfo.current.deviceInfoString
        )

        // TODO: Remove this after refactoring errors
        checkToken().then { _ -> Promise<Device> in
            if let savedDeviceId = DeviceDefaults.sharedDefaults.deviceId, !forceCreation {
                print("NotificationsRegistrationService: retrieve device by saved deviceId = \(savedDeviceId)")
                return ApiDataDownloader.devices.retrieve(deviceId: savedDeviceId)
            } else {
                return ApiDataDownloader.devices.create(newDevice)
            }
        }.then { remoteDevice -> Promise<Device> in
            if remoteDevice.isBadgesEnabled {
                return .value(remoteDevice)
            } else {
                remoteDevice.isBadgesEnabled = true
                return ApiDataDownloader.devices.update(remoteDevice)
            }
        }.done { device in
            print("NotificationsRegistrationService: device registered, info = \(device.json)")
            DeviceDefaults.sharedDefaults.deviceId = device.id
        }.catch { error in
            switch error {
            case DeviceError.notFound:
                print("NotificationsRegistrationService: device not found, create new")
                self.registerDevice(registrationToken, forceCreation: true)
            case DeviceError.other(_, _, let message):
                print("NotificationsRegistrationService: device registration error, error = \(String(describing: message))")
                StepikAnalytics.shared.send(.errorRegisterDevice(message: String(describing: message)))
            default:
                print("NotificationsRegistrationService: device registration error, error = \(error)")
                StepikAnalytics.shared.send(.errorRegisterDevice(message: error.localizedDescription))
            }
        }
    }

    // MARK: - Firebase -

    private func setAPNsTokenToFirebaseMessaging(apnsToken: Data) {
        Messaging.messaging().apnsToken = apnsToken
    }

    private func fetchFirebaseMessagingRegistrationToken() {
        Messaging.messaging().token { (token, error) in
            if let error = error {
                print("NotificationsRegistrationService: error while fetching FCM token: \(error)")
            } else if let token = token {
                self.registerDevice(token)
            }
        }
    }

    // MARK: - Unregister -

    func unregisterForRemoteNotifications() -> Guarantee<Void> {
        Guarantee { seal in
            UIApplication.shared.unregisterForRemoteNotifications()

            if let deviceID = DeviceDefaults.sharedDefaults.deviceId {
                ApiDataDownloader.devices.delete(deviceID).done { () in
                    print("NotificationsRegistrationService: successfully delete device, id = \(deviceID)")
                    seal(())
                }.catch { error in
                    switch error {
                    case DeviceError.notFound:
                        print("NotificationsRegistrationService: device not found on deletion, id = \(deviceID)")
                    default:
                        if let userID = AuthInfo.shared.userId,
                           let token = AuthInfo.shared.token {
                            let deleteTask = DeleteDeviceExecutableTask(userId: userID, deviceId: deviceID)
                            ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue.push(deleteTask)

                            let userPersistenceManager = PersistentUserTokenRecoveryManager(baseName: "Users")
                            userPersistenceManager.writeStepicToken(token, userId: userID)

                            let taskPersistenceManager = PersistentTaskRecoveryManager(baseName: "Tasks")
                            taskPersistenceManager.writeTask(deleteTask, name: deleteTask.id)

                            let queuePersistenceManager = PersistentQueueRecoveryManager(baseName: "Queues")
                            queuePersistenceManager.writeQueue(
                                ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue,
                                key: ExecutionQueues.connectionAvailableExecutionQueueKey
                            )
                        } else {
                            print(
                                "NotificationsRegistrationService: can't get current user ID or token to delete device"
                            )
                            StepikAnalytics.shared.send(.errorUnregisterDeviceInvalidCredentials)
                        }
                    }
                    seal(())
                }
            } else {
                print("NotificationsRegistrationService: no saved device")
                seal(())
            }
        }
    }
}

// MARK: - NotificationsRegistrationService (UserDefaults) -

extension NotificationsRegistrationService {
    private static let didShowDefaultPermissionAlertKey = "didShowDefaultPermissionAlertKey"
    private static let isFirstRegistrationIsInProgressKey = "isFirstRegistrationIsInProgressKey"

    private var didShowDefaultPermissionAlert: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.didShowDefaultPermissionAlertKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.didShowDefaultPermissionAlertKey)
        }
    }

    private var isFirstRegistrationIsInProgress: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.isFirstRegistrationIsInProgressKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.isFirstRegistrationIsInProgressKey)
        }
    }
}

// MARK: - NotificationsRegistrationService (NotificationCenter) -

extension Foundation.Notification.Name {
    static let notificationsRegistrationServiceWillOpenSettings = Foundation.Notification
        .Name("notificationsRegistrationServiceWillOpenSettings")
}
