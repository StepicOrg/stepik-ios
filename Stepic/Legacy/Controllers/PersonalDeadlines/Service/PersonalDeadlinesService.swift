//
//  PersonalDeadlinesService.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol PersonalDeadlinesServiceProtocol: AnyObject {
    func canAddDeadlines(in course: Course) -> Bool
    func countDeadlines(for course: Course, mode: DeadlineMode) -> Promise<Void>
    func syncDeadline(for course: Course, userID: Int) -> Promise<Void>
    func syncDeadlines(for courses: [Course], userID: User.IdType) -> Promise<Void>
    func changeDeadline(for course: Course, newDeadlines: [SectionDeadline]) -> Promise<Void>
    func deleteDeadline(for course: Course) -> Promise<Void>
    func hasDeadlines(in course: Course) -> Bool
}

final class PersonalDeadlinesService: PersonalDeadlinesServiceProtocol {
    var counter: PersonalDeadlinesTimeServiceProtocol
    var storageRecordsAPI: StorageRecordsAPI
    var localStorageManager: PersonalDeadlineLocalStorageManager
    var notificationsService: NotificationsService

    init(
        counter: PersonalDeadlinesTimeServiceProtocol = PersonalDeadlinesTimeService(),
        storageRecordsAPI: StorageRecordsAPI = StorageRecordsAPI(),
        localStorageManager: PersonalDeadlineLocalStorageManager = PersonalDeadlineLocalStorageManager(),
        notificationsService: NotificationsService = NotificationsService()
    ) {
        self.counter = counter
        self.storageRecordsAPI = storageRecordsAPI
        self.localStorageManager = localStorageManager
        self.notificationsService = notificationsService
    }

    func canAddDeadlines(in course: Course) -> Bool {
        course.sectionDeadlines == nil && course.scheduleType == .selfPaced
    }

    func hasDeadlines(in course: Course) -> Bool {
        course.sectionDeadlines != nil
    }

    func countDeadlines(for course: Course, mode: DeadlineMode) -> Promise<Void> {
        Promise { seal in
            counter.countDeadlines(mode: mode, for: course).then {
                sectionDeadlines -> Promise<StorageRecord> in
                let data = DeadlineStorageRecordData(courseID: course.id, deadlines: sectionDeadlines)
                let record = StorageRecord(data: data, kind: StorageRecordKind.deadline(courseID: course.id))
                return self.storageRecordsAPI.create(record: record)
            }.done { createdRecord in
                self.localStorageManager.set(storageRecord: createdRecord, for: course)
                self.notificationsService.updatePersonalDeadlineLocalNotifications(course: course)
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func syncDeadlines(for courses: [Course], userID: User.IdType) -> Promise<Void> {
        Promise { seal in
            self.storageRecordsAPI.retrieve(userID: userID, kindPrefixType: .deadline).done { storageRecords, _ in
                if storageRecords.isEmpty {
                    courses.forEach { course in
                        self.localStorageManager.deleteRecord(for: course)
                        self.notificationsService.updatePersonalDeadlineLocalNotifications(course: course)
                    }
                    seal.fulfill(())
                } else {
                    storageRecords.forEach { storageRecord in
                        if case .deadline(let courseID)? = storageRecord.kind,
                           let course = courses.first(where: { $0.id == courseID }) {
                            self.localStorageManager.set(storageRecord: storageRecord, for: course)
                            self.notificationsService.updatePersonalDeadlineLocalNotifications(course: course)
                        }
                    }
                    seal.fulfill(())
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func syncDeadline(for course: Course, userID: Int) -> Promise<Void> {
        Promise { seal in
            self.storageRecordsAPI.retrieve(
                userID: userID,
                kind: .deadline(courseID: course.id)
            ).done { storageRecords, _ in
                guard let storageRecord = storageRecords.first else {
                    self.localStorageManager.deleteRecord(for: course)
                    self.notificationsService.updatePersonalDeadlineLocalNotifications(course: course)
                    seal.fulfill(())
                    return
                }
                self.localStorageManager.set(storageRecord: storageRecord, for: course)
                self.notificationsService.updatePersonalDeadlineLocalNotifications(course: course)
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum DeadlineChangeError: Error {
        case noLocalRecord
    }

    func changeDeadline(for course: Course, newDeadlines: [SectionDeadline]) -> Promise<Void> {
        Promise { seal in
            guard let record = localStorageManager.getRecord(for: course) else {
                seal.reject(DeadlineChangeError.noLocalRecord)
                return
            }
            guard let dataToChange = record.data as? DeadlineStorageRecordData else {
                seal.reject(DeadlineChangeError.noLocalRecord)
                return
            }
            dataToChange.deadlines = newDeadlines
            record.data = dataToChange
            storageRecordsAPI.update(record: record).done { updatedRecord in
                self.localStorageManager.set(storageRecord: updatedRecord, for: course)
                self.notificationsService.updatePersonalDeadlineLocalNotifications(course: course)
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func deleteDeadline(for course: Course) -> Promise<Void> {
        Promise { seal in
            guard let record = localStorageManager.getRecord(for: course) else {
                seal.fulfill(())
                return
            }
            storageRecordsAPI.delete(id: record.id).done { _ in
                self.notificationsService.removePersonalDeadlineLocalNotifications(course: course)
                self.localStorageManager.deleteRecord(for: course)
                seal.fulfill(())
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }
}
