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

final class NotificationsRegistrationService {
    func getCurrentPermissionStatus() -> Guarantee<NotificationPermissionStatus> {
        print("NotificationsRegistrationService: \(#function)")

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

    // MARK: - Register -

    func register(forceToRequestAuthorization: Bool = false, authInfo: AuthInfo = .shared) {
        print("NotificationsRegistrationService: \(#function)")

        guard authInfo.isAuthorized else {
            return
        }

        if forceToRequestAuthorization {
            self.registerForRemoteNotifications()
        } else {
            self.registerIfHasPreviouslyRegistered()
        }
    }

    private func registerIfHasPreviouslyRegistered() {
        print("NotificationsRegistrationService: \(#function)")

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
        print("NotificationsRegistrationService: \(#function)")

        defer {
            self.fetchFirebaseAppInstanceID()
        }

        guard StepicApplicationsInfo.shouldRegisterNotifications else {
            return
        }

        if #available(iOS 10.0, *) {
            self.getCurrentPermissionStatus().done { status in
                if status == .denied {
                    self.showSettingsAlert()
                } else {
                    self.requestAuthorization()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }

    @available(iOS 10.0, *)
    private func requestAuthorization() {
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
    }

    private func retrieveDeviceToken() {
        func registerForRemoteNotifications() {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        print("NotificationsRegistrationService: \(#function)")

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

    func showSettingsAlert() {
        guard let controller = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        let alert = UIAlertController(
            title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""),
            message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Yes", comment: ""),
                style: .default,
                handler: { _ in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))

        controller.present(alert, animated: true)
    }

    func handleRegisteredNotificationSettings(_ notificationSettings: UIUserNotificationSettings) {
        print("NotificationsRegistrationService: \(#function), settings: \(notificationSettings)")

        if notificationSettings.types != [] {
            self.retrieveDeviceToken()
        }
    }

    // MARK: - Firebase -

    private func fetchFirebaseAppInstanceID() {
        print("NotificationsRegistrationService: \(#function)")

        InstanceID.instanceID().instanceID { [weak self] (result, error) in
            if let error = error {
                print("Error fetching Firebase remote instanse ID: \(error)")
            } else if let result = result {
                self?.registerDevice(result.token)
            }
        }
    }

    func getGCMRegistrationToken(deviceToken: Data) {
        print("NotificationsRegistrationService: \(#function) 🚀🚀🚀")

        Messaging.messaging().apnsToken = deviceToken
    }

    func registerDevice(_ registrationToken: String, forceCreation: Bool = false) {
        print("NotificationsRegistrationService: \(#function); Registration Token: \(registrationToken)")

        let newDevice = Device(registrationId: registrationToken, deviceDescription: DeviceInfo.current.deviceInfoString)

        //TODO: Remove this after refactoring errors
        checkToken().then { _ -> Promise<Device> in
            if let savedDeviceId = DeviceDefaults.sharedDefaults.deviceId, !forceCreation {
                print("notification registrator: retrieve device by saved deviceId = \(savedDeviceId)")
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
            print("notification registrator: device registered, info = \(device.json)")
            DeviceDefaults.sharedDefaults.deviceId = device.id
        }.catch { error in
            switch error {
            case DeviceError.notFound:
                print("notification registrator: device not found, create new")
                self.registerDevice(registrationToken, forceCreation: true)
            case DeviceError.other(_, _, let message):
                print("notification registrator: device registration error, error = \(String(describing: message))")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.registerDevice, parameters: ["message": "\(String(describing: message))"])
            default:
                print("notification registrator: device registration error, error = \(error)")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.registerDevice, parameters: ["message": "\(error.localizedDescription)"])
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
        print("NotificationsRegistrationService: \(#function)")
        return Guarantee { seal in
            UIApplication.shared.unregisterForRemoteNotifications()

            if let deviceId = DeviceDefaults.sharedDefaults.deviceId {
                ApiDataDownloader.devices.delete(deviceId).done { () in
                    print("notification registrator: successfully delete device, id = \(deviceId)")
                    seal(())
                }.catch { error in
                    switch error {
                    case DeviceError.notFound:
                        print("notification registrator: device not found on deletion, id = \(deviceId)")
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
                            print("notification registrator: could not get current user ID or token to delete device")
                            AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.unregisterDeviceInvalidCredentials)
                        }
                    }
                    seal(())
                }
            } else {
                print("notification registrator: no saved device")
                seal(())
            }
        }
    }
}
