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
        return Guarantee<NotificationPermissionStatus> { seal in
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    seal(NotificationPermissionStatus(authorizationStatus: settings.authorizationStatus))
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

    func registerForNotifications(forceToRequestAuthorization: Bool = false) {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        if forceToRequestAuthorization {
            self.register()
        } else {
            self.registerIfHasPreviouslyRegistered()
        }
    }

    private func registerIfHasPreviouslyRegistered() {
        if #available(iOS 10.0, *) {
            self.getCurrentPermissionStatus().done { status in
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
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { granted, _ in
                    if granted {
                        self.retrieveDeviceToken()
                    }
                }
            )
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    private func retrieveDeviceToken() {
        self.getCurrentPermissionStatus().done { status in
            guard status.isRegistered else {
                return
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // MARK: - Firebase -

    private func fetchFirebaseAppInstanceID() {
        InstanceID.instanceID().instanceID { [weak self] (result, error) in
            if let error = error {
                print("Error fetching Firebase remote instanse ID: \(error)")
            } else if let result = result {
                self?.registerDevice(result.token)
            }
        }
    }

    func getGCMRegistrationToken(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func registerDevice(_ registrationToken: String, forceCreation: Bool = false) {
        print("Registration Token: \(registrationToken)")

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
