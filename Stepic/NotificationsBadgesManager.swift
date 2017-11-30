//
//  NotificationsBadgesManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let badgeUpdated = NSNotification.Name("badgeUpdated")
}

class NotificationsBadgesManager {
    static let shared = NotificationsBadgesManager()

    private var badgeValues = Set<Int>()

    private(set) var notificationsCount: Int = 0 {
        didSet {
            NotificationCenter.default.post(name: .badgeUpdated, object: self, userInfo: ["value": notificationsCount])
        }
    }

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didNotificationUpdate(systemNotification:)), name: .notificationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didAllNotificationsRead(systemNotification:)), name: .allNotificationsMarkedAsRead, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didNotificationAdd(systemNotification:)), name: .notificationAdded, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup() { }

    @objc func didNotificationUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let status = userInfo["status"] as? NotificationStatus else {
                return
        }

        if status == .read {
            notificationsCount -= 1
            badgeValues.insert(notificationsCount)
        }
    }

    @objc func didNotificationAdd(systemNotification: Foundation.Notification) {
        notificationsCount += 1
        badgeValues.insert(notificationsCount)
    }

    @objc func didAllNotificationsRead(systemNotification: Foundation.Notification) {
        notificationsCount = 0
        badgeValues.insert(notificationsCount)
    }

    func set(number: Int) {
        if !badgeValues.contains(number) {
            notificationsCount = number
        } else {
            badgeValues.remove(number)
        }
    }
}
