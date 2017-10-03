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

    func set(notifications: [NotificationViewData])
}

enum NotificationsViewState {
    case normal, refresh, loading, empty
}

enum NotificationsSection {
    case all, learning, comments, reviews, teaching, other
}

struct NotificationViewData {
    var text: String
}

class NotificationsPresenter {
    weak var view: NotificationsView?

    var notificationsAPI: NotificationsAPI

    private var page = 1
    private var section: NotificationsSection = .all

    init(section: NotificationsSection, notificationsAPI: NotificationsAPI, view: NotificationsView) {
        self.section = section
        self.notificationsAPI = notificationsAPI
        self.view = view
    }

    func refresh() {
        view?.state = .refresh

        page = 1

        // Reload and
        view?.state = .normal
    }

    func load() {
        view?.state = .refresh

        // TODO: Fetch saved in Core Data
        fetchNotifications(success: { notifications in
            self.view?.state = .normal
            self.view?.set(notifications: notifications.map { NotificationViewData(text: $0.htmlText ?? "") })
        }, failure: { error in
            // FIXME: handle error here
            print(error)
        })
    }

    fileprivate func fetchNotifications(success: @escaping ([Notification]) -> Void, failure: @escaping (RetrieveError) -> Void) {
        var type: Notification.`Type`? = nil

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
