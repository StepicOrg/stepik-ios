//
//  NotificationsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import PromiseKit

protocol NotificationsView: AnyObject {
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

final class NotificationsPresenter {
    weak var view: NotificationsView?

    private let notificationsAPI: NotificationsAPI
    private let usersAPI: UsersAPI
    private let notificationsStatusAPI: NotificationStatusesAPI
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let notificationSuggestionManager: NotificationSuggestionManager
    private var page = 1
    private var hasNextPage = true
    private var displayedNotifications: NotificationViewDataStruct = []

    private let analytics: Analytics

    private var section: NotificationsSection = .all

    // Store unread notifications count to pass it to analytics
    private var badgeUnreadCount = 0

    init(
        section: NotificationsSection,
        notificationsAPI: NotificationsAPI,
        usersAPI: UsersAPI,
        notificationsStatusAPI: NotificationStatusesAPI,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        notificationSuggestionManager: NotificationSuggestionManager,
        analytics: Analytics,
        view: NotificationsView
    ) {
        self.section = section
        self.notificationsAPI = notificationsAPI
        self.usersAPI = usersAPI
        self.notificationsStatusAPI = notificationsStatusAPI
        self.notificationsRegistrationService = notificationsRegistrationService
        self.notificationSuggestionManager = notificationSuggestionManager
        self.analytics = analytics
        self.view = view

        self.notificationsRegistrationService.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didNotificationUpdate(systemNotification:)),
            name: .notificationUpdated, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didAllNotificationsRead),
            name: .allNotificationsMarkedAsRead, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didNotificationAdd(systemNotification:)),
            name: .notificationAdded, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didBadgeUpdate(systemNotification:)),
            name: .badgeUpdated, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didLogout),
            name: .didLogout, object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func didLogout() {
        displayedNotifications = []
        view?.set(notifications: displayedNotifications, withReload: true)
    }

    @objc
    private func didBadgeUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let value = userInfo["value"] as? Int else {
            return
        }

        self.badgeUnreadCount = value
    }

    @objc
    private func didNotificationUpdate(systemNotification: Foundation.Notification) {
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

    @objc
    private func didNotificationAdd(systemNotification: Foundation.Notification) {
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

    @objc
    private func didAllNotificationsRead() {
        self.displayedNotifications = self.displayedNotifications.map { arg -> (date: Date, notifications: [NotificationViewData]) in
            let (date, notifications) = arg
            return (date: date, notifications: self.updateNotificationsViewData(notifications: notifications, newStatus: .read))
        }
        self.view?.set(notifications: self.displayedNotifications, withReload: true)
    }

    func didAppear() {
        self.notificationsRegistrationService.registerForRemoteNotifications()
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

    private func updateDisplayedNotifications(_ notifications: NotificationViewDataStruct) {
        self.displayedNotifications = notifications
        self.view?.set(notifications: self.displayedNotifications, withReload: true)
    }

    private func loadCached() -> Guarantee<NotificationViewDataStruct> {
        let notifications = Notification.fetch(type: section.notificationType, offset: 0, limit: 50)
        return merge(old: self.displayedNotifications, new: notifications ?? [])
    }

    private func loadData(page: Int, in section: NotificationsSection) -> Promise<(Bool, NotificationViewDataStruct)> {
        Promise { seal in
            var hasNext = false
            self.notificationsAPI.retrieve(
                page: page,
                notificationType: section.notificationType
            ).then { result, meta -> Guarantee<NotificationViewDataStruct> in
                hasNext = meta.hasNext
                return self.merge(old: self.displayedNotifications, new: result)
            }.done { results in
                seal.fulfill((hasNext, results))
            }.catch { seal.reject($0) }
        }
    }

    private func merge(old: NotificationViewDataStruct, new: [Notification]) -> Guarantee<NotificationViewDataStruct> {
        // id -> url
        var userAvatars: [Int: URL] = [:]
        var usersQuery: Set<Int> = Set()

        // Extract all user id and cache data extractors
        var notificationsWExtractor: [(Notification, NotificationDataExtractor)] = []
        for notification in new {
            let extractor = NotificationDataExtractor(text: notification.htmlText ?? "", type: notification.type)
            if let userId = extractor.userID {
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
                if let userId = extractor.userID, let userAvatar = userAvatars[userId] {
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
            CoreDataHelper.shared.save()
            NotificationCenter.default.post(name: .notificationUpdated, object: self, userInfo: ["section": self.section, "id": id, "status": status])
        }.catch { error in
            print("notifications: unable to update notification, id = \(id), error = \(error)")
        }
    }

    func markAllAsRead() {
        self.view?.updateMarkAllAsReadButton(with: .loading)

        self.notificationsAPI.markAllAsRead().done { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            Notification.markAllAsRead()
            strongSelf.analytics.send(.markAllNotificationsAsReadTapped(badgeUnreadCount: strongSelf.badgeUnreadCount))

            NotificationCenter.default.post(
                name: .allNotificationsMarkedAsRead,
                object: strongSelf,
                userInfo: ["section": strongSelf.section]
            )

            strongSelf.view?.updateMarkAllAsReadButton(with: .normal)
        }.catch { [weak self] error in
            print("notifications: unable to mark all notifications as read, error = \(error)")
            self?.view?.updateMarkAllAsReadButton(with: .error)
        }
    }

    private func updateNotificationsViewData(
        notifications: [NotificationViewData],
        newStatus: NotificationStatus,
        ids: [Int]? = nil
    ) -> [NotificationViewData] {
        notifications.map { notification in
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
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        shouldPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) -> Bool {
        self.notificationSuggestionManager.canShowAlert(context: .notificationsTab)
    }

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        didPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) {
        self.notificationSuggestionManager.didShowAlert(context: .notificationsTab)
    }
}
