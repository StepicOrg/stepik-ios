//
//  NotificationRegistrator.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FirebaseCore
import FirebaseInstanceID
import PromiseKit
import UserNotifications

final class NotificationRegistrator {
    static let shared = NotificationRegistrator()

    private let notificationPermissionManager = NotificationPermissionManager()

    private init () {
    }
}

// MARK: - NotificationRegistrator (Register) -

extension NotificationRegistrator {
    func registerForRemoteNotificationsIfAlreadyAsked() {
        if #available(iOS 10.0, *) {
            notificationPermissionManager.getCurrentPermissionStatus().done { [weak self] status in
                guard status == .authorized else {
                    return
                }
                self?.registerForRemoteNotifications()
            }
        } else {
            registerForRemoteNotifications()
        }
    }

    // TODO: Remove UIApplication usage
    func registerForRemoteNotifications(application: UIApplication = UIApplication.shared) {
        if StepicApplicationsInfo.shouldRegisterNotifications {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .badge, .sound],
                    completionHandler: { _, _  in }
                )
            } else {
                let settings = UIUserNotificationSettings(
                    types: [.alert, .badge, .sound],
                    categories: nil
                )
                application.registerUserNotificationSettings(settings)
            }
            application.registerForRemoteNotifications()
        }

        if AuthInfo.shared.isAuthorized {
            InstanceID.instanceID().instanceID { [weak self] (result, error) in
                if let error = error {
                    print("Error fetching Firebase remote instanse ID: \(error)")
                } else if let result = result {
                    self?.registerDevice(result.token)
                }
            }
        }
    }

    func getGCMRegistrationToken(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func registerDevice(_ registrationToken: String, forceCreation: Bool = false) {
        print("Registration Token: \(registrationToken)")

        let newDevice = Device(
            registrationId: registrationToken,
            deviceDescription: DeviceInfo.current.deviceInfoString
        )

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
        }.done { device in
            print("notification registrator: device registered, info = \(device.json)")
            DeviceDefaults.sharedDefaults.deviceId = device.id
        }.catch { error in
            switch error {
            case DeviceError.notFound:
                print("notification registrator: device not found, create new")
                self.registerDevice(registrationToken, forceCreation: true)
            case DeviceError.other(_, _, let message):
                print("notification registrator: device registration error, error = \(String(describing: message))")
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Errors.registerDevice,
                    parameters: ["message": "\(String(describing: message))"]
                )
            default:
                print("notification registrator: device registration error, error = \(error)")
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Errors.registerDevice,
                    parameters: ["message": "\(error.localizedDescription)"]
                )
            }
        }
    }
}

// MARK: - NotificationRegistrator (Unregister) -

extension NotificationRegistrator {
    @available(*, deprecated, message: "Legacy method with callbacks")
    func unregisterFromNotifications(completion: @escaping (() -> Void)) {
        unregisterFromNotifications().done {
            completion()
        }.catch { _ in }
    }

    func unregisterFromNotifications() -> Guarantee<Void> {
        return Guarantee { seal in
            UIApplication.shared.unregisterForRemoteNotifications()

            guard let deviceId = DeviceDefaults.sharedDefaults.deviceId else {
                print("notification registrator: no saved device")
                return seal(())
            }

            ApiDataDownloader.devices.delete(deviceId).done {
                print("notification registrator: successfully delete device, id = \(deviceId)")
                seal(())
            }.catch { [weak self] error in
                switch error {
                case DeviceError.notFound:
                    print("notification registrator: device not found on deletion, id = \(deviceId)")
                default:
                    if let userId = AuthInfo.shared.userId,
                       let token = AuthInfo.shared.token {
                        self?.deleteDevice(deviceId: deviceId, userId: userId, token: token)
                    } else {
                        print("notification registrator: could not get current user ID or token to delete device")
                        AnalyticsReporter.reportEvent(
                            AnalyticsEvents.Errors.unregisterDeviceInvalidCredentials
                        )
                    }
                }
                seal(())
            }
        }
    }

    private func deleteDevice(deviceId: Int, userId: Int, token: StepicToken) {
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
    }
}
