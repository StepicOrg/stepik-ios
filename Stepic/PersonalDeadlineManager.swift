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

    static let shared = PersonalDeadlineManager(counter: PersonalDeadlineCounter(), storageRecordsAPI: StorageRecordsAPI(), localStorageManager: PersonalDeadlineLocalStorageManager(), notificationManager: PersonalDeadlineNotificationsManager())

    init(counter: PersonalDeadlineCounter, storageRecordsAPI: StorageRecordsAPI, localStorageManager: PersonalDeadlineLocalStorageManager, notificationManager: PersonalDeadlineNotificationsManager) {
        self.counter = counter
        self.storageRecordsAPI = storageRecordsAPI
        self.localStorageManager = localStorageManager
        self.notificationManager = notificationManager
    }

    func countDeadlines(for course: Course, mode: DeadlineMode) -> Promise<Void> {
        return Promise { seal in
            counter.countDeadlines(mode: mode, for: course).then {
                sectionDeadlines -> Promise<StorageRecord> in
                let data = DeadlineStorageData(courseID: course.id, deadlines: sectionDeadlines)
                let record = StorageRecord(data: data, kind: StorageKind.deadline(courseID: course.id))
                return self.storageRecordsAPI.create(record: record)
            }.done { createdRecord in
                self.localStorageManager.set(storageRecord: createdRecord, for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func syncDeadline(for course: Course, userID: Int) -> Promise<Void> {
        return Promise { seal in
            storageRecordsAPI.retrieve(kind: StorageKind.deadline(courseID: course.id), user: userID).done { storageRecords, _ in
                guard let storageRecord = storageRecords.first else {
                    self.localStorageManager.deleteRecord(for: course)
                    self.notificationManager.updateDeadlineNotifications(for: course)
                    seal.fulfill(())
                    return
                }
                self.localStorageManager.set(storageRecord: storageRecord, for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                seal.fulfill(())
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    enum DeadlineChangeError: Error {
        case noLocalRecord
    }

    func changeDeadline(for course: Course, newDeadlines: [SectionDeadline]) -> Promise<Void> {
        return Promise { seal in
            guard let record = localStorageManager.getRecord(for: course) else {
                seal.reject(DeadlineChangeError.noLocalRecord)
                return
            }
            guard let dataToChange = record.data as? DeadlineStorageData else {
                seal.reject(DeadlineChangeError.noLocalRecord)
                return
            }
            dataToChange.deadlines = newDeadlines
            record.data = dataToChange
            storageRecordsAPI.update(record: record).done { updatedRecord in
                self.localStorageManager.set(storageRecord: updatedRecord, for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func deleteDeadline(for course: Course) -> Promise<Void> {
        return Promise { seal in
            guard let record = localStorageManager.getRecord(for: course) else {
                seal.fulfill(())
                return
            }
            storageRecordsAPI.delete(id: record.id).done { _ in
                self.localStorageManager.deleteRecord(for: course)
                self.notificationManager.updateDeadlineNotifications(for: course)
                seal.fulfill(())
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

}
