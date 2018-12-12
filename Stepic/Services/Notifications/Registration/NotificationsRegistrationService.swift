//
//  NotificationsRegistrationService.swift
//  Stepic
//
//  Created by Ivan Magda on 19/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import FirebaseMessaging
import FirebaseCore
import FirebaseInstanceID
import PromiseKit
import UserNotifications

final class NotificationsRegistrationService: NotificationsRegistrationServiceProtocol {
    weak var delegate: NotificationsRegistrationServiceDelegate?
    var presenter: NotificationsRegistrationPresentationServiceProtocol?
    private var analytics: NotificationAlertsAnalytics?

    private let splitTestingService: SplitTestingServiceProtocol

    init(
        delegate: NotificationsRegistrationServiceDelegate? = nil,
        presenter: NotificationsRegistrationPresentationServiceProtocol? = nil,
        analytics: NotificationAlertsAnalytics? = nil,
        splitTestingService: SplitTestingServiceProtocol = SplitTestingService(
            analyticsService: AnalyticsUserProperties(),
            storage: UserDefaults.standard
        )
    ) {
        self.delegate = delegate
        self.presenter = presenter
        self.analytics = analytics
        self.splitTestingService = splitTestingService
    }

    // MARK: - Handling APNs pipeline events -

    func handleDeviceToken(_ deviceToken: Data) {
        print("NotificationsRegistrationService: did register for remote notifications")
        self.getGCMRegistrationToken(deviceToken: deviceToken)
        self.postCurrentPermissionStatus()
        self.delegate?.notificationsRegistrationServiceDidSuccessfullyRegisterWithAPNs(self)
    }

    func handleRegistrationError(_ error: Error) {
        print("NotificationsRegistrationService: did fail register with error: \(error)")
        self.postCurrentPermissionStatus()
        self.delegate?.notificationsRegistrationServiceDidFailRegisterWithAPNs(self, error: error)
    }

    func handleRegisteredNotificationSettings(_ notificationSettings: UIUserNotificationSettings) {
        print("NotificationsRegistrationService: registered with settings: \(notificationSettings)")

        let granted = notificationSettings.types != []

        if self.isFirstRegistrationIsInProgress {
            self.isFirstRegistrationIsInProgress = false
            self.analytics?.reportDefaultAlertInteractionResult(granted ? .yes : .no)
        }

        if granted {
            self.registerWithAPNs()
        } else {
            self.postCurrentPermissionStatus()
        }
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
        let subscribeSplitTest = self.splitTestingService.fetchSplitTest(SubscribeNotificationsOnLaunchSplitTest.self)
        let shouldParticipate = SubscribeNotificationsOnLaunchSplitTest.shouldParticipate
            && subscribeSplitTest.currentGroup.shouldShowOnFirstLaunch
        guard AuthInfo.shared.isAuthorized || shouldParticipate else {
            return
        }

        self.postCurrentPermissionStatus()

        if forceToRequestAuthorization {
            self.register()
        } else {
            self.registerIfAuthorized()
        }
    }

    private func registerIfAuthorized() {
        if #available(iOS 10.0, *) {
            NotificationPermissionStatus.current.done { status in
                if status.isRegistered {
                    self.register()
                }
            }
        } else {
            self.register()
        }
    }

    private func register() {
        defer {
            self.fetchFirebaseAppInstanceID()
        }

        guard StepicApplicationsInfo.shouldRegisterNotifications else {
            return
        }

        if #available(iOS 10.0, *) {
            NotificationPermissionStatus.current.done { status in
                if status == .denied {
                    self.presentSettingsAlertIfNeeded()
                } else {
                    self.presentPermissionAlertIfNeeded()
                }
            }
        } else {
            self.presentPermissionAlertIfNeeded()
        }
    }

    /// Prompts the user to authorize with desired notifications settings.
    private func requestAuthorization() {
        if !self.didShowDefaultPermissionAlert {
            self.analytics?.reportDefaultAlertShown()
            self.isFirstRegistrationIsInProgress = true
        }

        self.didShowDefaultPermissionAlert = true

        if #available(iOS 10.0, *) {
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
                }
            )
        } else {
            let notificationSettings = UIUserNotificationSettings(
                types: [.alert, .badge, .sound],
                categories: nil
            )
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
    }

    /// Initiates the registration process with Apple Push Notification service.
    private func registerWithAPNs() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
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

            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
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

        //TODO: Remove this after refactoring errors
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
        }.done { device -> Void in
            print("NotificationsRegistrationService: device registered, info = \(device.json)")
            DeviceDefaults.sharedDefaults.deviceId = device.id
        }.catch { error in
            switch error {
            case DeviceError.notFound:
                print("NotificationsRegistrationService: device not found, create new")
                self.registerDevice(registrationToken, forceCreation: true)
            case DeviceError.other(_, _, let message):
                print("NotificationsRegistrationService: device registration error, error = \(String(describing: message))")
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Errors.registerDevice,
                    parameters: ["message": "\(String(describing: message))"]
                )
            default:
                print("NotificationsRegistrationService: device registration error, error = \(error)")
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Errors.registerDevice,
                    parameters: ["message": "\(error.localizedDescription)"]
                )
            }
        }
    }

    // MARK: - Firebase -

    private func getGCMRegistrationToken(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    private func fetchFirebaseAppInstanceID() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("NotificationsRegistrationService: error while fetching Firebase remote instance ID: \(error)")
            } else if let result = result {
                self.registerDevice(result.token)
            }
        }
    }

    // MARK: - Unregister -

    @available(*, deprecated, message: "Legacy method with callbacks")
    func unregisterFromNotifications(completion: @escaping (() -> Void)) {
        self.unregisterFromNotifications().done {
            completion()
        }.catch { _ in
        }
    }

    func unregisterFromNotifications() -> Guarantee<Void> {
        return Guarantee { seal in
            UIApplication.shared.unregisterForRemoteNotifications()

            if let deviceId = DeviceDefaults.sharedDefaults.deviceId {
                ApiDataDownloader.devices.delete(deviceId).done { () in
                    print("NotificationsRegistrationService: successfully delete device, id = \(deviceId)")
                    seal(())
                }.catch { error in
                    switch error {
                    case DeviceError.notFound:
                        print("NotificationsRegistrationService: device not found on deletion, id = \(deviceId)")
                    default:
                        if let userId = AuthInfo.shared.userId,
                           let token = AuthInfo.shared.token {

                            let deleteTask = DeleteDeviceExecutableTask(userId: userId, deviceId: deviceId)
                            ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue.push(deleteTask)

                            let userPersistencyManager = PersistentUserTokenRecoveryManager(baseName: "Users")
                            userPersistencyManager.writeStepicToken(token, userId: userId)

                            let taskPersistencyManager = PersistentTaskRecoveryManager(baseName: "Tasks")
                            taskPersistencyManager.writeTask(deleteTask, name: deleteTask.id)

                            let queuePersistencyManager = PersistentQueueRecoveryManager(baseName: "Queues")
                            queuePersistencyManager.writeQueue(
                                ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue,
                                key: ExecutionQueues.sharedQueues.connectionAvailableExecutionQueueKey
                            )
                        } else {
                            print("NotificationsRegistrationService: could not get current user ID or token to delete device")
                            AnalyticsReporter.reportEvent(
                                AnalyticsEvents.Errors.unregisterDeviceInvalidCredentials
                            )
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
            return UserDefaults.standard.bool(
                forKey: NotificationsRegistrationService.didShowDefaultPermissionAlertKey
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: NotificationsRegistrationService.didShowDefaultPermissionAlertKey
            )
        }
    }

    private var isFirstRegistrationIsInProgress: Bool {
        get {
            return UserDefaults.standard.bool(
                forKey: NotificationsRegistrationService.isFirstRegistrationIsInProgressKey
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: NotificationsRegistrationService.isFirstRegistrationIsInProgressKey
            )
        }
    }
}
