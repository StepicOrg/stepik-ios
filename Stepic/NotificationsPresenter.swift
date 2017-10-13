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
        // TODO: Fetch saved in Core Data
        fetchNotifications(success: { meta, notifications in
            // id -> url
            var userAvatars: [Int: URL] = [:]
            var usersQuery: Set<Int> = Set()

            var notificationsWExtractor: [(Notification, NotificationDataExtractor)] = []
            for notification in notifications {
                let extractor = NotificationDataExtractor(text: notification.htmlText ?? "", type: notification.type)
                if let userId = extractor.userId {
                    usersQuery.insert(userId)
                }
                notificationsWExtractor.append((notification, extractor))
            }

            self.usersAPI.retrieve(ids: Array(usersQuery), existing: [], refreshMode: .update, success: { users in
                users.forEach { user in
                    userAvatars[user.id] = URL(string: user.avatarURL)
                }

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
                for val in self.displayedNotifications {
                    if dateToNotifications[val.date] != nil {
                        dateToNotifications[val.date]?.append(contentsOf: val.notifications)
                    } else {
                        dateToNotifications[val.date] = val.notifications
                    }
                }

                var notificationsOut: NotificationViewDataStruct = []
                for (key, value) in dateToNotifications {
                    notificationsOut.append((date: key, notifications: value))
                }

                notificationsOut.sort { $0.date > $1.date }

                self.displayedNotifications = notificationsOut
                self.page += 1
                success(meta.hasNext, self.displayedNotifications)
            }, error: { error in
                // FIXME: handle error here
                print(error)
            })
        }, failure: { error in
            // FIXME: handle error here
            print(error)
        })
    }

    func updateNotification(with id: Int, status: NotificationStatus) {
        guard let notification = Notification.fetch(id) else {
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

    fileprivate func fetchNotifications(success: @escaping (Meta, [Notification]) -> Void, failure: @escaping (RetrieveError) -> Void) {
        var type: NotificationType? = nil

        switch section {
        case .comments:
            type = .comments
        case .teaching:
            type = .teach
        case .reviews:
            type = .review
        case .learning:
            type = .learn
        case .other:
            type = .`default`
        default:
            type = nil
        }

        notificationsAPI.retrieve(page: page, notificationType: type, success: { success($0, $1) }, error: { failure($0) })
    }
}
