//
//  NotificationBannerType.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol NotificationBanner {
    func show()
    func dismiss()
}

enum NotificationBannerType {
    case achievement(data: AchievementViewData)

    var banner: NotificationBanner {
        switch self {
        case .achievement(let data):
            let view: AchievementNotificationBannerView = AchievementNotificationBannerView.fromNib()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.data = data
            return CustomNotificationBanner(view: view)
        }
    }
}
