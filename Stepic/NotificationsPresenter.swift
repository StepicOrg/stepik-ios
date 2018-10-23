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

extension NSNotification.Name {
    static let notificationUpdated = NSNotification.Name("notificationUpdated")
    static let allNotificationsMarkedAsRead = NSNotification.Name("allNotificationsMarkedAsRead")
    static let notificationAdded = NSNotification.Name("notificationAdded")
}

class NotificationsPresenter {
    weak var view: NotificationsView?

    var notificationsAPI: NotificationsAPI
    var usersAPI: UsersAPI
    var notificationsStatusAPI: NotificationStatusesAPI
    var notificationsRegistrationService: NotificationsRegistrationService
    var notificationSuggestionManager: NotificationSuggestionManager
    private var page = 1
    var hasNextPage = true
    private var displayedNotifications: NotificationViewDataStruct = []

    private var section: NotificationsSection = .all

    // Store unread notifications count to pass it to analytics
    private var badgeUnreadCount = 0

    init(section: NotificationsSection, notificationsAPI: NotificationsAPI, usersAPI: UsersAPI, notificationsStatusAPI: NotificationStatusesAPI, notificationsRegistrationService: NotificationsRegistrationService, notificationSuggestionManager: NotificationSuggestionManager, view: NotificationsView) {
        self.section = section
        self.notificationsAPI = notificationsAPI
        self.usersAPI = usersAPI
        self.notificationsStatusAPI = notificationsStatusAPI
        self.notificationsRegistrationService = notificationsRegistrationService
        self.notificationSuggestionManager = notificationSuggestionManager
        self.view = view

        self.notificationsRegistrationService.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(self.didNotificationUpdate(systemNotification:)), name: .notificationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didAllNotificationsRead(systemNotification:)), name: .allNotificationsMarkedAsRead, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didNotificationAdd(systemNotification:)), name: .notificationAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBadgeUpdate(systemNotification:)), name: .badgeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didLogout(systemNotification:)), name: .didLogout, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didLogout(systemNotification: Foundation.Notification) {
        displayedNotifications = []
        view?.set(notifications: displayedNotifications, withReload: true)
    }

    @objc func didBadgeUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
            let value = userInfo["value"] as? Int else {
                return
        }

        self.badgeUnreadCount = value
    }

    @objc func didNotificationUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let firedSection = userInfo["section"] as? NotificationsSection,
              let id = userInfo["id"] as? Int,
              let status = userInfo["status"] as? NotificationStatus else {
                return
        }

        self.displayedNotifications = self.displayedNotifications.map { arg -> (date: Date, notifications: [NotificationViewData]) in
            let (date, notifications) = arg
            return (date: date, notifications: self.updateNotificationsViewData(notifications: notifications, newStatus: status, ids: [id]))
        }
        self.view?.set(notifications: self.displayedNotifications, withReload: firedSection != self.section)
    }

    @objc func didNotificationAdd(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let id = userInfo["id"] as? Int else {
            return
        }

        guard let addedNotification = Notification.fetch(id: id) else {
            return
        }

        merge(old: self.displayedNotifications, new: [addedNotification]).done { result in
            self.displayedNotifications = result
            self.view?.set(notifications: self.displayedNotifications, withReload: true)
        }
    }

    @objc func didAllNotificationsRead(systemNotification: Foundation.Notification) {
        self.displayedNotifications = self.displayedNotifications.map { arg -> (date: Date, notifications: [NotificationViewData]) in
            let (date, notifications) = arg
            return (date: date, notifications: self.updateNotificationsViewData(notifications: notifications, newStatus: .read))
        }
        self.view?.set(notifications: self.displayedNotifications, withReload: true)
    }

    func didAppear() {
        self.notificationsRegistrationService.register(forceToRequestAuthorization: true)
    }

    func refresh() {
        view?.state = .refreshing
        page = 1
        hasNextPage = true
        displayedNotifications = []

        loadData(page: 1, in: self.section).done { hasNextPage, result in
            self.hasNextPage = hasNextPage

            self.updateDisplayedNotifications(result)
        }.ensure {
            self.view?.state = .normal
        }.catch { error in
            print("notifications: refresh error = \(error)")
        }

        loadStatuses()
    }

    func loadInitial() {
        view?.state = .refreshing

        var isNotificationsEmpty = false
        loadCached().then { result -> Promise<(Bool, NotificationViewDataStruct)> in
            self.updateDisplayedNotifications(result)

            return self.loadData(page: 1, in: self.section)
        }.done { hasNextPage, result in
            self.hasNextPage = hasNextPage
            self.page += 1

            isNotificationsEmpty = result.isEmpty
            self.updateDisplayedNotifications(result)
        }.ensure {
            if isNotificationsEmpty {
                self.view?.state = .empty
            } else {
                self.view?.state = .normal
            }
        }.catch { error in
            print("notifications: load initial error = \(error)")
        }

        loadStatuses()
    }

    func loadNextPage() {
        guard hasNextPage else {
            return
        }

        view?.state = .loading

        loadData(page: page, in: section).done { hasNextPage, result in
            self.hasNextPage = hasNextPage
            self.page += 1

            self.updateDisplayedNotifications(result)
        }.ensure {
            self.view?.state = .normal
        }.catch { error in
            print("notifications: load next page error = \(error)")
        }
    }

    fileprivate func updateDisplayedNotifications(_ notifications: NotificationViewDataStruct) {
        self.displayedNotifications = notifications
        self.view?.set(notifications: self.displayedNotifications, withReload: true)
    }

    fileprivate func loadCached() -> Guarantee<NotificationViewDataStruct> {
        let notifications = Notification.fetch(type: section.notificationType, offset: 0, limit: 50)
        return merge(old: self.displayedNotifications, new: notifications ?? [])
    }

    fileprivate func loadData(page: Int, in section: NotificationsSection) -> Promise<(Bool, NotificationViewDataStruct)> {
        return Promise { seal in
            var hasNext: Bool = false
            notificationsAPI.retrieve(page: page, notificationType: section.notificationType).then { result, meta -> Guarantee<NotificationViewDataStruct> in
                hasNext = meta.hasNext

                return self.merge(old: self.displayedNotifications, new: result)
            }.done { results in
                seal.fulfill((hasNext, results))
            }.catch { seal.reject($0) }
        }
    }

    fileprivate func merge(old: NotificationViewDataStruct, new: [Notification]) -> Guarantee<NotificationViewDataStruct> {
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
        return Guarantee { seal in
            usersAPI.retrieve(ids: Array(usersQuery), existing: []).done { users in
                users.forEach { user in
                    userAvatars[user.id] = URL(string: user.avatarURL)
                }
                seal(groupNotificationsByDate())
            }.catch { _ in
                seal(groupNotificationsByDate())
            }
        }
    }

    func updateNotification(with id: Int, status: NotificationStatus) {
        guard let notification = Notification.fetch(id: id) else {
            print("notifications: unable to find notification with id = \(id)")
            return
        }

        notification.status = status
        self.notificationsAPI.update(notification).done { _ in
            CoreDataHelper.instance.save()
            NotificationCenter.default.post(name: .notificationUpdated, object: self, userInfo: ["section": self.section, "id": id, "status": status])
        }.catch { error in
            print("notifications: unable to update notification, id = \(id), error = \(error)")
        }
    }

    func markAllAsRead() {
        view?.updateMarkAllAsReadButton(with: .loading)

        notificationsAPI.markAllAsRead().done { _ in
            Notification.markAllAsRead()
            AnalyticsReporter.reportEvent(AnalyticsEvents.Notifications.markAllAsRead, parameters: ["badge": self.badgeUnreadCount])

            NotificationCenter.default.post(name: .allNotificationsMarkedAsRead, object: self, userInfo: ["section": self.section])
            self.view?.updateMarkAllAsReadButton(with: .normal)
        }.catch { error in
            print("notifications: unable to mark all notifications as read, error = \(error)")
            self.view?.updateMarkAllAsReadButton(with: .error)
        }
    }

    private func updateNotificationsViewData(notifications: [NotificationViewData], newStatus: NotificationStatus, ids: [Int]? = nil) -> [NotificationViewData] {
        return notifications.map { notification in
            var editedNotification = notification
            editedNotification.status = newStatus
            return (ids?.contains(editedNotification.id) ?? true) ? editedNotification : notification
        }
    }

    private func loadStatuses() {
        notificationsStatusAPI.retrieve().done { statuses in
            NotificationsBadgesManager.shared.set(number: statuses.totalCount)
        }.catch { error in
            print("notifications: unable to load statuses, error = \(error)")
        }
    }
}

// MARK: - NotificationsPresenter: NotificationsRegistrationServiceDelegate -

extension NotificationsPresenter: NotificationsRegistrationServiceDelegate {
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationService,
        willPresentAlertFor alertType: NotificationsRegistrationService.AlertType
    ) -> Bool {
        return self.notificationSuggestionManager.canShowAlert(context: .notificationsTab)
    }

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationService,
        didPresentAlertFor alertType: NotificationsRegistrationService.AlertType
    ) {
        if alertType == .permission {
            self.notificationSuggestionManager.didShowAlert(context: .notificationsTab)
        }
    }
}
