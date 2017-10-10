//
//  NotificationsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol NotificationsView: class {
    var state: NotificationsViewState { get set }

    func set(notifications: NotificationViewDataStruct)
}

enum NotificationsViewState {
    case normal, refreshing, loading, empty
}

enum NotificationsSection {
    case all, learning, comments, reviews, teaching, other
}

typealias NotificationViewDataStruct = [(date: Date, notifications: [NotificationViewData])]

struct NotificationViewData {
    var type: NotificationType
    var time: Date
    var text: String
    var avatarURL: URL?
}

class NotificationsPresenter {
    weak var view: NotificationsView?

    var notificationsAPI: NotificationsAPI
    var usersAPI: UsersAPI

    private var page = 1
    private var hasNext = true
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
        loadData(page: page) { hasNext, notifications in
            self.hasNext = hasNext

            self.view?.state = .normal
            self.view?.set(notifications: notifications)
        }
    }

    func load() {
        view?.state = .loading

        if hasNext || page == 1 {
            loadData(page: page) { hasNext, notifications in
                self.hasNext = hasNext

                self.view?.state = .normal
                self.view?.set(notifications: notifications)
            }
        } else {
            self.view?.state = .normal
        }
    }

    fileprivate func loadData(page: Int, success: @escaping (Bool, NotificationViewDataStruct) -> Void) {
        // TODO: Fetch saved in Core Data
        fetchNotifications(success: { notifications in
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
                        notificationVD = NotificationViewData(type: notification.type, time: notification.time ?? Date(), text: extractor.preparedText ?? "", avatarURL: userAvatar)
                    } else {
                        notificationVD = NotificationViewData(type: notification.type, time: notification.time ?? Date(), text: extractor.preparedText ?? "", avatarURL: nil)
                    }

                    let timestampDropHours = Int(notificationVD.time.timeIntervalSince1970 / (24 * 60 * 60)) * 24 * 60 * 60
                    let day = Date(timeIntervalSince1970: Double(timestampDropHours))
                    if !dateToNotifications.keys.contains(day) {
                        dateToNotifications[day] = []
                    }
                    dateToNotifications[day]?.append(notificationVD)
                }

                var notificationsOut: NotificationViewDataStruct = []
                for (key, value) in dateToNotifications {
                    notificationsOut.append((date: key, notifications: value))
                }
                notificationsOut.sort { $0.date > $1.date }

                print(notificationsOut)
                success(false, notificationsOut)
            }, error: { error in
                // FIXME: handle error here
                print(error)
            })
        }, failure: { error in
            // FIXME: handle error here
            print(error)
        })
    }

    fileprivate func fetchNotifications(success: @escaping ([Notification]) -> Void, failure: @escaping (RetrieveError) -> Void) {
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

        notificationsAPI.retrieve(page: page, notificationType: type, success: { success($0) }, error: { failure($0) })
    }
}
