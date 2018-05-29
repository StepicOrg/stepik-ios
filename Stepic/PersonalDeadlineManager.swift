//
//  PersonalDeadlineManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class PersonalDeadlineManager {
    var counter: PersonalDeadlineCounter
    var storageRecordsAPI: StorageRecordsAPI
    var localStorageManager: PersonalDeadlineLocalStorageManager
    var notificationManager: PersonalDeadlineNotificationsManager

    init(counter: PersonalDeadlineCounter, storageRecordsAPI: StorageRecordsAPI, localStorageManager: PersonalDeadlineLocalStorageManager, notificationManager: PersonalDeadlineNotificationsManager) {
        self.counter = counter
        self.storageRecordsAPI = storageRecordsAPI
        self.localStorageManager = localStorageManager
        self.notificationManager = notificationManager
    }

    func countDeadlines(for course: Course, mode: DeadlineMode) -> Promise<Void> {
        return Promise {
            fulfill, reject in
            counter.countDeadlines(mode: mode, for: course).then {
                sectionDeadlines -> Promise<StorageRecord> in
                let data = DeadlineStorageData(courseID: course.id, deadlines: sectionDeadlines)
                let record = StorageRecord(data: data, kind: StorageKind.deadline(courseID: course.id))
                return self.storageRecordsAPI.create(record: record)
            }.then {
                createdRecord -> Void in
                self.localStorageManager.set(storageRecord: createdRecord, for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                fulfill(())
            }.catch {
                error in
                reject(error)
            }
        }
    }
    
    func syncDeadline(for course: Course, userID: Int) -> Promise<Void> {
        return Promise {
            fulfill, reject in
            storageRecordsAPI.retrieve(kind: StorageKind.deadline(courseID: course.id), user: userID).then {
                storageRecords, meta -> Void in
                guard let storageRecord = storageRecords.first else {
                    fulfill(())
                    return
                }
                self.localStorageManager.set(storageRecord: storageRecord, for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                fulfill(())
            }.catch {
                error in
                reject(error)
            }
        }
    }
    
    func deleteDeadline(for course: Course) -> Promise<Void> {
        return Promise {
            fulfill, reject in
            guard let record = localStorageManager.getRecord(for: course) else {
                fulfill(())
                return
            }
            storageRecordsAPI.delete(id: record.id).then {
                () -> Void in
                self.localStorageManager.deleteRecord(for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                fulfill(())
            }.catch {
                error in
                reject(error)
            }
        }
    }
    
}
