//
//  NotificationsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

protocol NotificationsView: class {
    var state: NotificationsViewState { get set }

    func set(notifications: NotificationViewDataStruct, withReload: Bool)
    func updateMarkAllAsReadButton(with status: NotificationsMarkAsReadButton.Status)
}

enum NotificationsViewState {
    case normal, refreshing, loading, empty
}

typealias NotificationViewDataStruct = [(date: Date, notifications: [NotificationViewData])]

struct NotificationViewData {
    var id: Int
    var type: NotificationType
    var status: NotificationStatus
    var time: Date
    var text: String
    var avatarURL: URL?
}

class NotificationsPresenter {
    weak var view: NotificationsView?

    var notificationsAPI: NotificationsAPI
    var usersAPI: UsersAPI

    private var page = 1
    var hasNextPage = true
    private var displayedNotifications: NotificationViewDataStruct = []

    private var section: NotificationsSection = .all

    init(section: NotificationsSection, notificationsAPI: NotificationsAPI, usersAPI: UsersAPI, view: NotificationsView) {
        self.section = section
        self.notificationsAPI = notificationsAPI
        self.usersAPI = usersAPI
        self.view = view
    }

    func refresh() {
        view?.state = .refreshing
        page = 1
        hasNextPage = true
        displayedNotifications = []

        loadData(page: 1, in: self.section).then { hasNextPage, result -> Void in
            self.hasNextPage = hasNextPage

            self.updateDisplayedNotifications(result)
        }.catch { error in
            print("notifications: refresh error = \(error)")
        }.always {
            self.view?.state = .normal
        }
    }

    func loadInitial() {
        view?.state = .refreshing

        var isNotificationsEmpty = false
        loadCached().then { result -> Promise<(Bool, NotificationViewDataStruct)> in
            self.updateDisplayedNotifications(result)

            return self.loadData(page: 1, in: self.section)
        }.then { hasNextPage, result -> Void in
            self.hasNextPage = hasNextPage
            self.page += 1

            isNotificationsEmpty = result.isEmpty
            self.updateDisplayedNotifications(result)
        }.catch { error in
            print("notifications: load initial error = \(error)")
        }.always {
            if isNotificationsEmpty {
                self.view?.state = .empty
            } else {
                self.view?.state = .normal
            }
        }
    }

    func loadNextPage() {
        guard hasNextPage else {
            return
        }

        view?.state = .loading

        loadData(page: page, in: section).then { hasNextPage, result -> Void in
            self.hasNextPage = hasNextPage
            self.page += 1

            self.updateDisplayedNotifications(result)
        }.always {
            self.view?.state = .normal
        }.catch { error in
            print("notifications: load next page error = \(error)")
        }
    }

    fileprivate func updateDisplayedNotifications(_ notifications: NotificationViewDataStruct) {
        self.displayedNotifications = notifications
        self.view?.set(notifications: self.displayedNotifications, withReload: true)
    }

    fileprivate func loadCached() -> Promise<NotificationViewDataStruct> {
        let notifications = Notification.fetch(type: section.notificationType, offset: 0, limit: 50)
        return merge(old: self.displayedNotifications, new: notifications ?? [])
    }

    fileprivate func loadData(page: Int, in section: NotificationsSection) -> Promise<(Bool, NotificationViewDataStruct)> {
        return Promise { fulfill, reject in
            var hasNext: Bool = false
            checkToken().then { _ -> Promise<(Meta, [Notification])> in
                self.notificationsAPI.retrieve(page: page, notificationType: section.notificationType)
            }.then { meta, result -> Promise<NotificationViewDataStruct> in
                hasNext = meta.hasNext

                return self.merge(old: self.displayedNotifications, new: result)
            }.then { results -> Void in
                fulfill((hasNext, results))
            }.catch { reject($0) }
        }
    }

    fileprivate func merge(old: NotificationViewDataStruct, new: [Notification]) -> Promise<NotificationViewDataStruct> {
        // id -> url
        var userAvatars: [Int: URL] = [:]
        var usersQuery: Set<Int> = Set()

        // Extract all user id and cache data extractors
        var notificationsWExtractor: [(Notification, NotificationDataExtractor)] = []
        for notification in new {
            let extractor = NotificationDataExtractor(text: notification.htmlText ?? "", type: notification.type)
            if let userId = extractor.userId {
                usersQuery.insert(userId)
            }
            notificationsWExtractor.append((notification, extractor))
        }

        // Group notifications by date
        // Return dict: date -> notifications
        func groupNotificationsByDate() -> NotificationViewDataStruct {
            var dateToNotifications: [Date: [NotificationViewData]] = [:]

            // Add avatator URL to view data
            notificationsWExtractor.forEach { notification, extractor in
                let notificationVD: NotificationViewData!
                if let userId = extractor.userId, let userAvatar = userAvatars[userId] {
                    notificationVD = NotificationViewData(id: notification.id, type: notification.type, status: notification.status, time: notification.time ?? Date(), text: extractor.preparedText ?? "", avatarURL: userAvatar)
                } else {
                    notificationVD = NotificationViewData(id: notification.id, type: notification.type, status: notification.status, time: notification.time ?? Date(), text: extractor.preparedText ?? "", avatarURL: nil)
                }

                let secondsInDay = 24 * 60 * 60
                let timestampDropHours = Int(notificationVD.time.timeIntervalSince1970 / Double(secondsInDay)) * secondsInDay
                let day = Date(timeIntervalSince1970: Double(timestampDropHours))
                if !dateToNotifications.keys.contains(day) {
                    dateToNotifications[day] = []
                }
                dateToNotifications[day]?.append(notificationVD)
            }

            // Get already displayed notifications from view and merge with new
            for val in old {
                if dateToNotifications[val.date] != nil {
                    dateToNotifications[val.date]?.append(contentsOf: val.notifications)
                } else {
                    dateToNotifications[val.date] = val.notifications
                }
            }

            // Remove duplicates
            var notificationsOut: NotificationViewDataStruct = []
            var isUnique: [Int: Bool] = [:]
            for (key, value) in dateToNotifications {
                var uniqueValue = value.filter {
                    isUnique.updateValue(false, forKey: $0.id) ?? true
                }
                uniqueValue.sort { $0.time > $1.time }
                notificationsOut.append((date: key, notifications: uniqueValue))
            }

            // Sort by date
            notificationsOut.sort { $0.date > $1.date }
            return notificationsOut
        }

        // Try to load user avatars and group notifications
        return Promise { fulfill, _ in
            checkToken().then { _ -> Promise<[User]> in
                self.usersAPI.retrieve(ids: Array(usersQuery), existing: [])
            }.then { users -> Void in
                users.forEach { user in
                    userAvatars[user.id] = URL(string: user.avatarURL)
                }
                fulfill(groupNotificationsByDate())
            }.catch { _ in
                fulfill(groupNotificationsByDate())
            }
        }
    }

    func updateNotification(with id: Int, status: NotificationStatus) {
        guard let notification = Notification.fetch(id: id) else {
            print("notifications: unable to find notification with id = \(id)")
            return
        }

        notification.status = status
        checkToken().then { _ -> Promise<Notification> in
            self.notificationsAPI.update(notification)
        }.then { notification -> Void in
            CoreDataHelper.instance.save()

            self.displayedNotifications = self.displayedNotifications.map { arg -> (date: Date, notifications: [NotificationViewData]) in
                let (date, notifications) = arg
                return (date: date, notifications: notifications.map { notification in
                    var openedNotification = notification
                    openedNotification.status = .read
                    return openedNotification.id == id ? openedNotification : notification
                })
            }
            self.view?.set(notifications: self.displayedNotifications, withReload: false)
        }.catch { error in
            print("notifications: unable to update notification, id = \(id), error = \(error)")
        }
    }

    func markAllAsRead() {
        view?.updateMarkAllAsReadButton(with: .loading)

        checkToken().then { _ -> Promise<()> in
            self.notificationsAPI.markAllAsRead()
        }.then { _ -> Void in
            Notification.markAllAsRead()
            self.displayedNotifications = self.displayedNotifications.map { arg -> (date: Date, notifications: [NotificationViewData]) in
                let (date, notifications) = arg
                return (date: date, notifications: notifications.map { notification in
                    var openedNotification = notification
                    openedNotification.status = .read
                    return openedNotification
                })
            }
            self.view?.set(notifications: self.displayedNotifications, withReload: true)
            self.view?.updateMarkAllAsReadButton(with: .normal)
        }.catch { error in
            print("notifications: unable to mark all notifications as read, error = \(error)")
            self.view?.updateMarkAllAsReadButton(with: .error)
        }
    }
}
