//
//  NotificationsBadgesManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class NotificationsBadgesManager {
    static let shared = NotificationsBadgesManager()

    var notificationsCount: Int = 0 {
        didSet {
            (UIApplication.shared.delegate as? AppDelegate)?.notificationsBadgeNumber = notificationsCount
        }
    }

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didNotificationUpdate(systemNotification:)), name: .notificationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didAllNotificationsRead(systemNotification:)), name: .allNotificationsMarkedAsRead, object: nil)
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
        }
    }

    @objc func didAllNotificationsRead(systemNotification: Foundation.Notification) {
        notificationsCount = 0
    }

}
