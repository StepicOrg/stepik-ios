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
    var presenter: NotificationsRegistrationServicePresenterProtocol?

    init(
        delegate: NotificationsRegistrationServiceDelegate? = nil,
        presenter: NotificationsRegistrationServicePresenterProtocol? = nil
    ) {
        self.delegate = delegate
        self.presenter = presenter
    }

    // MARK: - Handling APNs pipeline events -

    func handleDeviceToken(_ deviceToken: Data) {
        print("NotificationsRegistrationService: did register for remote notifications 🚀🚀🚀")
        self.getGCMRegistrationToken(deviceToken: deviceToken)
        self.postCurrentPermissionStatus()
        self.delegate?.notificationsRegistrationServiceDidSuccessfullyRegisterWithAPNs(self)
    }

    func handleRegistrationError(_ error: Error) {
        print("NotificationsRegistrationService: did fail register 😱😱😱 with error: \(error)")
        self.postCurrentPermissionStatus()
        self.delegate?.notificationsRegistrationServiceDidFailRegisteredWithAPNs(self, error: error)
    }

    func handleRegisteredNotificationSettings(_ notificationSettings: UIUserNotificationSettings) {
        print("NotificationsRegistrationService: registered with settings: \(notificationSettings)")
        if notificationSettings.types != [] {
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
        guard AuthInfo.shared.isAuthorized else {
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
            NotificationPermissionStatus.current().done { status in
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

        let isDelegateAllow = self.delegate?.notificationsRegistrationService(self,
            shouldPresentAlertFor: .permission) ?? false
        let shouldPresentCustomPermissionAlert = self.presenter != nil && isDelegateAllow

        if shouldPresentCustomPermissionAlert {
            self.presentPermissionAlert()
        } else if #available(iOS 10.0, *) {
            NotificationPermissionStatus.current().done { status in
                if status == .denied {
                    self.presentSettingsAlert()
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
        self.didShowPermissionAlert = true

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { granted, error in
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
        if self.didShowPermissionAlert || self.presenter == nil {
            self.requestAuthorization()
        } else {
            self.presentPermissionAlert()
        }
    }

    private func presentPermissionAlert() {
        let originalCallback = self.presenter?.onPositiveCallback
        self.presenter?.onPositiveCallback = {
            originalCallback?()
            NotificationPermissionStatus.current().done { status in
                if status == .denied {
                    self.presentAlert(for: .settings)
                } else {
                    self.requestAuthorization()
                }
            }
        }

        self.presentAlert(for: .permission)
    }

    private func presentSettingsAlert() {
        if let delegate = self.delegate {
            if delegate.notificationsRegistrationService(self, shouldPresentAlertFor: .settings) {
                self.presentAlert(for: .settings)
            }
        } else {
            self.presentAlert(for: .settings)
        }
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

    func registerDevice(_ registrationToken: String, forceCreation: Bool = false) {
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

    func getGCMRegistrationToken(deviceToken: Data) {
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
    private static let didShowPermissionAlertKey = "didShowPermissionAlertKey"

    private var didShowPermissionAlert: Bool {
        get {
            return UserDefaults.standard.bool(forKey: NotificationsRegistrationService.didShowPermissionAlertKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificationsRegistrationService.didShowPermissionAlertKey)
        }
    }
}
