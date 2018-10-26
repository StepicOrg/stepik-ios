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

protocol NotificationsRegistrationServiceDelegate: class {
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationService,
        willPresentAlertFor alertType: NotificationsRegistrationService.AlertType
    ) -> Bool

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationService,
        didPresentAlertFor alertType: NotificationsRegistrationService.AlertType
    )
}

final class NotificationsRegistrationService {
    weak var delegate: NotificationsRegistrationServiceDelegate?
    private var alertProvider: NotificationsRegistrationServiceAlertProvider

    init(
        delegate: NotificationsRegistrationServiceDelegate? = nil,
        alertProvider: NotificationsRegistrationServiceAlertProvider = DefaultNotificationsRegistrationServiceAlertProvider()
    ) {
        self.delegate = delegate
        self.alertProvider = alertProvider
    }

    // MARK: - Permission Status

    func getCurrentPermissionStatus() -> Guarantee<NotificationPermissionStatus> {
        return Guarantee<NotificationPermissionStatus> { seal in
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().getNotificationSettings {
                    seal(NotificationPermissionStatus(authorizationStatus: $0.authorizationStatus))
                }
            } else {
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    seal(.authorized)
                } else {
                    seal(.notDetermined)
                }
            }
        }
    }

    // MARK: - Handling -

    func handleDeviceToken(_ deviceToken: Data) {
        print("NotificationsRegistrationService: did register for remote notifications 🚀🚀🚀")
        self.getGCMRegistrationToken(deviceToken: deviceToken)
        self.postCurrentPermissionStatus()
    }

    func handleRegistrationError(_ error: Error) {
        print("NotificationsRegistrationService: did fail register with error: \(error)")
        self.postCurrentPermissionStatus()
    }

    func handleRegisteredNotificationSettings(_ notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != [] {
            self.retrieveDeviceToken()
        } else {
            self.postCurrentPermissionStatus()
        }
    }

    // MARK: - Register -

    func register(forceToRequestAuthorization: Bool = false) {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        self.postCurrentPermissionStatus()

        if forceToRequestAuthorization {
            self.registerForRemoteNotifications()
        } else {
            self.registerIfHasPreviouslyRegistered()
        }
    }

    private func registerIfHasPreviouslyRegistered() {
        if #available(iOS 10.0, *) {
            self.getCurrentPermissionStatus().done { status in
                if status.isRegistered {
                    self.registerForRemoteNotifications()
                }
            }
        } else {
            self.registerForRemoteNotifications()
        }
    }

    private func registerForRemoteNotifications() {
        defer {
            self.fetchFirebaseAppInstanceID()
        }

        guard StepicApplicationsInfo.shouldRegisterNotifications else {
            return
        }

        if self.delegate?.notificationsRegistrationService(self, willPresentAlertFor: .permission) ?? false {
            self.showPermissionAlert()
        } else if #available(iOS 10.0, *) {
            self.getCurrentPermissionStatus().done { status in
                if status == .denied {
                    self.showSettingsAlert()
                } else {
                    self.showPermissionAlertIfFirstTime()
                }
            }
        } else {
            self.showPermissionAlertIfFirstTime()
        }
    }

    private func requestAuthorization() {
        self.didShowPermissionAlert = true

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { granted, error in
                    if granted {
                        self.retrieveDeviceToken()
                    } else if let error = error {
                        print("NotificationsRegistrationService: \(#function); error: \(error)")
                    }
                }
            )
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }

    private func retrieveDeviceToken() {
        func registerForRemoteNotifications() {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        if #available(iOS 10.0, *) {
            self.getCurrentPermissionStatus().done { status in
                if status.isRegistered {
                    registerForRemoteNotifications()
                }
            }
        } else {
            registerForRemoteNotifications()
        }
    }

    private func showSettingsAlert() {
        if let delegate = self.delegate {
            if delegate.notificationsRegistrationService(self, willPresentAlertFor: .settings) {
                self.presentAlert(for: .settings)
            }
        } else {
            self.presentAlert(for: .settings)
        }
    }

    private func showPermissionAlertIfFirstTime() {
        if self.didShowPermissionAlert {
            self.requestAuthorization()
        } else {
            self.showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
        self.alertProvider.onPositiveCallback = {
            self.getCurrentPermissionStatus().done { status in
                if status == .denied {
                    self.presentAlert(for: .settings)
                } else {
                    self.requestAuthorization()
                }
            }
        }

        if let delegate = self.delegate {
            if delegate.notificationsRegistrationService(self, willPresentAlertFor: .permission) {
                self.presentAlert(for: .permission)
            }
        } else {
            self.presentAlert(for: .permission)
        }
    }

    private func presentAlert(for type: AlertType) {
        guard let rootViewController = SourcelessRouter().window?.rootViewController else {
            return
        }

        self.getCurrentPermissionStatus().done { status in
            if status.isRegistered {
                return
            }

            DispatchQueue.main.async {
                self.alertProvider.presentAlert(for: type, inController: rootViewController)
                self.delegate?.notificationsRegistrationService(self, didPresentAlertFor: type)
            }
        }
    }

    // MARK: Device

    func registerDevice(_ registrationToken: String, forceCreation: Bool = false) {
        let newDevice = Device(registrationId: registrationToken, deviceDescription: DeviceInfo.current.deviceInfoString)

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
                AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.registerDevice, parameters: ["message": "\(String(describing: message))"])
            default:
                print("NotificationsRegistrationService: device registration error, error = \(error)")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.registerDevice, parameters: ["message": "\(error.localizedDescription)"])
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
                print("Error fetching Firebase remote instanse ID: \(error)")
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
        }.catch { _ in }
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
                            queuePersistencyManager.writeQueue(ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue, key: ExecutionQueues.sharedQueues.connectionAvailableExecutionQueueKey)
                        } else {
                            print("NotificationsRegistrationService: could not get current user ID or token to delete device")
                            AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.unregisterDeviceInvalidCredentials)
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

    // MARK: - Inner Types

    enum AlertType {
        case permission
        case settings
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

// MARK: - NotificationsRegistrationService (NotificationCenter) -

extension Foundation.Notification.Name {
    static let notificationsRegistrationServiceDidUpdatePermissionStatus = Foundation.Notification.Name("notificationsRegistrationServiceDidUpdatePermissionStatus")
}

extension NotificationsRegistrationService {
    private func postCurrentPermissionStatus() {
        self.getCurrentPermissionStatus().done { status in
            NotificationCenter.default.post(
                name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
                object: status
            )
        }
    }
}
