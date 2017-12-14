//
//  NotificationRegistrator.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Firebase
import PromiseKit

class NotificationRegistrator {
    static let shared = NotificationRegistrator()

    private init () { }

    func registerForRemoteNotifications() {
        return registerForRemoteNotifications(UIApplication.shared)
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        if StepicApplicationsInfo.shouldRegisterNotifications {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }

        if AuthInfo.shared.isAuthorized {
            if let token = FIRInstanceID.instanceID().token() {
                registerDevice(token)
            }
        }
    }

    func getGCMRegistrationToken(deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
    }

    var registrationOptions = [String: AnyObject]()

    let registrationKey = "onRegistrationCompleted"

    func registerDevice(_ registrationToken: String!) {
        print("Registration Token: \(registrationToken)")

        let newDevice = Device(registrationId: registrationToken, deviceDescription: DeviceInfo.current.deviceInfoString)

        ApiDataDownloader.devices.retrieve(registrationId: registrationToken).then { device -> Promise<Device> in
            if let remoteDevice = device {
                return !remoteDevice.isBadgesEnabled ? ApiDataDownloader.devices.update(newDevice) : Promise(value: remoteDevice)
            } else {
                return ApiDataDownloader.devices.create(newDevice)
            }
        }.then { device -> Void in
            print("notification registrator: device registered, info = \(device.json)")
            DeviceDefaults.sharedDefaults.deviceId = device.id
        }.catch { error in
            print("notification registrator: device registration error, error = \(error)")
        }
    }

    func unregisterFromNotifications() -> Promise<Void> {
        return Promise { fulfill, _ in
            UIApplication.shared.unregisterForRemoteNotifications()

            if let deviceId = DeviceDefaults.sharedDefaults.deviceId {
                ApiDataDownloader.devices.delete(deviceId).then { () -> Void in
                    print("notification registrator: successfully delete device, id = \(deviceId)")
                    fulfill()
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

                            DeviceDefaults.sharedDefaults.deviceId = nil
                            fulfill()
                        } else {
                            print("notification registrator: could not get current user ID or token to delete device")
                            fulfill()
                        }
                        fulfill()
                    }
                }
            } else {
                print("notification registrator: no saved device")
                fulfill()
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
