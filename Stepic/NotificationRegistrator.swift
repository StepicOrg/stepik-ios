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

class NotificationRegistrator {
    static let shared = NotificationRegistrator()

    let notificationPermissionManager = NotificationPermissionManager()

    private init () { }

    func registerForRemoteNotificationsIfAlreadyAsked() {
        if #available(iOS 10.0, *) {
            notificationPermissionManager.getCurrentPermissionStatus().then {
                [weak self]
                status -> Void in
                switch status {
                case .authorized:
                    self?.registerForRemoteNotifications()
                default:
                    return
                }
            }
        } else {
            registerForRemoteNotifications()
        }
    }

    func registerForRemoteNotifications() {
        return registerForRemoteNotifications(UIApplication.shared)
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        if StepicApplicationsInfo.shouldRegisterNotifications {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {_, _ in})
            } else {
                let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }

        }

        if AuthInfo.shared.isAuthorized {
            if let token = InstanceID.instanceID().token() {
                registerDevice(token)
            }
        }
    }

    func getGCMRegistrationToken(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    var registrationOptions = [String: AnyObject]()

    let registrationKey = "onRegistrationCompleted"

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
        }.then { device -> Void in
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

    func unregisterFromNotifications() -> Promise<Void> {
        return Promise { fulfill, _ in
            UIApplication.shared.unregisterForRemoteNotifications()

            if let deviceId = DeviceDefaults.sharedDefaults.deviceId {
                ApiDataDownloader.devices.delete(deviceId).then { () -> Void in
                    print("notification registrator: successfully delete device, id = \(deviceId)")
                    fulfill(())
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
                    fulfill(())
                }
            } else {
                print("notification registrator: no saved device")
                fulfill(())
            }
        }
    }
}

extension NotificationRegistrator {
    @available(*, deprecated, message: "Legacy method with callbacks")
    func unregisterFromNotifications(completion: @escaping (() -> Void)) {
        unregisterFromNotifications().then {
            completion()
        }.catch { _ in }
    }
}
