//
//  CustomNotificationBanner.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import NotificationBannerSwift

class CustomNotificationBanner: NotificationBanner {
    private var banner: NotificationBannerSwift.NotificationBanner
    private weak var view: UIView?

    init(view: UIView) {
        self.view = view
        self.banner = NotificationBannerSwift.NotificationBanner(customView: view)
    }

    func show() {
        self.banner.show()
    }

    func dismiss() {
        self.banner.dismiss()
    }
}
