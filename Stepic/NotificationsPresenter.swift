//
//  NotificationsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

protocol NotificationsView: class {
    var state: NotificationsViewState { get set }

    func set(notifications: NotificationViewDataStruct)
    func updateMarkAllAsReadButton(with status: NotificationsMarkAsReadButton.Status)
}

enum NotificationsViewState {
    case normal, refreshing, loading, empty
}

enum NotificationsSection {
    var localizedName: String {
        let localizedNames: [NotificationsSection: String] = [
            .all: NSLocalizedString("NotificationsAll", comment: ""),
            .learning: NSLocalizedString("NotificationsLearning", comment: ""),
            .comments: NSLocalizedString("NotificationsComments", comment: ""),
            .reviews: NSLocalizedString("NotificationsReviews", comment: ""),
            .teaching: NSLocalizedString("NotificationsTeaching", comment: ""),
            .other: NSLocalizedString("NotificationsOther", comment: "")
        ]
        return localizedNames[self] ?? "Unknown"
    }

    case all, learning, comments, reviews, teaching, other
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
        loadData(page: page) { hasNext, notifications in
            self.hasNextPage = hasNext

            self.view?.state = .normal
            self.view?.set(notifications: notifications)
        }
    }

    func load() {
        if displayedNotifications.isEmpty && hasNextPage {
            // First loading, notifications not loaded yet -> load part from Core Data
            let notifications = Notification.fetch(type: sectionToType(section), offset: 0, limit: 50)
            merge(old: displayedNotifications, new: notifications ?? [], success: { result in
                self.displayedNotifications = result
                self.view?.set(notifications: self.displayedNotifications)
            }, failure: { err in
                // FIXME: handle error
                print(err)
            })
        }

        view?.state = .loading

        if hasNextPage || page == 1 {
            loadData(page: page) { hasNext, notifications in
                self.hasNextPage = hasNext

                self.view?.state = .normal
                self.view?.set(notifications: notifications)
            }
        } else {
            self.view?.state = .normal
        }
    }

    fileprivate func loadData(page: Int, success: @escaping (Bool, NotificationViewDataStruct) -> Void) {
        fetchNotifications(success: { meta, notifications in
            self.merge(old: self.displayedNotifications, new: notifications, success: { result in
                self.displayedNotifications = result
                self.page += 1
                success(meta.hasNext, self.displayedNotifications)
            }, failure: { err in
                // FIXME: handle error here
                print(err)
            })
        }, failure: { error in
            // FIXME: handle error here
            print(error)
        })
    }

    fileprivate func merge(old: NotificationViewDataStruct, new: [Notification], success: @escaping (NotificationViewDataStruct) -> Void, failure: @escaping (String) -> Void) {
        // id -> url
        var userAvatars: [Int: URL] = [:]
        var usersQuery: Set<Int> = Set()

        var notificationsWExtractor: [(Notification, NotificationDataExtractor)] = []
        for notification in new {
            let extractor = NotificationDataExtractor(text: notification.htmlText ?? "", type: notification.type)
            if let userId = extractor.userId {
                usersQuery.insert(userId)
            }
            notificationsWExtractor.append((notification, extractor))
        }

        func groupNotifications() -> NotificationViewDataStruct {
            // Group by date
            var dateToNotifications: [Date: [NotificationViewData]] = [:]

            notificationsWExtractor.forEach { notification, extractor in
                let notificationVD: NotificationViewData!
                if let userId = extractor.userId, let userAvatar = userAvatars[userId] {
                    notificationVD = NotificationViewData(id: notification.id, type: notification.type, status: notification.status, time: notification.time ?? Date(), text: extractor.preparedText ?? "", avatarURL: userAvatar)
                } else {
                    notificationVD = NotificationViewData(id: notification.id, type: notification.type, status: notification.status, time: notification.time ?? Date(), text: extractor.preparedText ?? "", avatarURL: nil)
                }

                let timestampDropHours = Int(notificationVD.time.timeIntervalSince1970 / (24 * 60 * 60)) * 24 * 60 * 60
                let day = Date(timeIntervalSince1970: Double(timestampDropHours))
                if !dateToNotifications.keys.contains(day) {
                    dateToNotifications[day] = []
                }
                dateToNotifications[day]?.append(notificationVD)
            }

            // Get already displayed notifications from view and merge
            for val in old {
                if dateToNotifications[val.date] != nil {
                    dateToNotifications[val.date]?.append(contentsOf: val.notifications)
                } else {
                    dateToNotifications[val.date] = val.notifications
                }
            }

            var notificationsOut: NotificationViewDataStruct = []
            var isUnique: [Int: Bool] = [:]
            for (key, value) in dateToNotifications {
                let uniqueValue = value.filter {
                    isUnique.updateValue(false, forKey: $0.id) ?? true
                }
                notificationsOut.append((date: key, notifications: uniqueValue))
            }

            notificationsOut.sort { $0.date > $1.date }
            return notificationsOut
        }

        self.usersAPI.retrieve(ids: Array(usersQuery), existing: [], refreshMode: .update, success: { users in
            users.forEach { user in
                userAvatars[user.id] = URL(string: user.avatarURL)
            }
            success(groupNotifications())
        }, error: { err in
            success(groupNotifications())
        })
    }

    func updateNotification(with id: Int, status: NotificationStatus) {
        guard let notification = Notification.fetch(id: id) else {
            print("notifications: unable to find notification with id = \(id)")
            return
        }

        notification.status = status
        if status == .opened {
            notificationsAPI.update(notification, success: { _ in }, error: { err in
                print("notifications: unable to update notification with id = \(id), error = \(err)")
            })
        }
        CoreDataHelper.instance.save()
    }

    func markAllAsRead() {
        view?.updateMarkAllAsReadButton(with: .loading)
        notificationsAPI.markAllAsRead(success: {
            self.displayedNotifications = self.displayedNotifications.map { arg -> (date: Date, notifications: [NotificationViewData]) in
                let (date, notifications) = arg
                return (date: date, notifications: notifications.map { notification in
                    var openedNotification = notification
                    openedNotification.status = .opened
                    return openedNotification
                })
            }

            self.view?.set(notifications: self.displayedNotifications)
            self.view?.updateMarkAllAsReadButton(with: .normal)
        }, error: { err in
            print("notifications: unable to mark all as read, error = \(err)")
            self.view?.updateMarkAllAsReadButton(with: .error)
        })
    }

    fileprivate func sectionToType(_ section: NotificationsSection) -> NotificationType? {
        switch section {
        case .comments:
            return .comments
        case .teaching:
            return .teach
        case .reviews:
            return .review
        case .learning:
            return .learn
        case .other:
            return .`default`
        default:
            return nil
        }

    }

    fileprivate func fetchNotifications(success: @escaping (Meta, [Notification]) -> Void, failure: @escaping (RetrieveError) -> Void) {
        let type: NotificationType? = sectionToType(section)
        notificationsAPI.retrieve(page: page, notificationType: type, success: { success($0, $1) }, error: { failure($0) })
    }
}
