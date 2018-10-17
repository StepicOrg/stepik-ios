//
//  TabBarRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class TabBarRouter: SourcelessRouter, RouterProtocol {
    let tab: Tab
    let notificationsSection: NotificationsSection

    init(tab: Tab) {
        self.tab = tab
        self.notificationsSection = .all
    }

    init(notificationsSection: NotificationsSection) {
        self.tab = .notifications
        self.notificationsSection = notificationsSection
    }

    func route() {
        self.currentTabBarController?.selectedIndex = self.tab.rawValue

        if self.tab == .notifications {
            selectNotificationsSection()
        }
    }

    private func selectNotificationsSection() {
        guard let navigationController = self.currentTabBarController?.viewControllers?[self.tab.rawValue] as? UINavigationController,
              let pager = navigationController.topViewController as? NotificationsPagerViewController else {
            return
        }

        if !pager.isViewLoaded,
           let sectionIndex = pager.sections.index(of: self.notificationsSection) {
            pager.startTabIndex = sectionIndex
        } else {
            pager.selectSection(self.notificationsSection)
        }
    }

    enum Tab: Int {
        case home
        case catalog
        case profile
        case certificates
        case notifications
    }
}
