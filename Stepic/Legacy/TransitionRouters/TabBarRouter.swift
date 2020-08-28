//
//  TabBarRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TabBarRouter: SourcelessRouter, RouterProtocol {
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
        self.currentTabBarController?.selectedIndex = self.tab.index

        switch self.tab {
        case .home, .profile:
            break
        case .catalog(let searchCourses):
            if searchCourses {
                self.displaySearchCourses()
            }
        case .notifications:
            self.selectNotificationsSection()
        }
    }

    private func displaySearchCourses() {
        guard let currentViewControllers = self.currentTabBarController?.viewControllers,
              let navigationController = currentViewControllers[safe: self.tab.index] as? UINavigationController,
              let exploreViewController = navigationController.topViewController as? ExploreViewController else {
            return
        }

        if exploreViewController.isViewLoaded {
            exploreViewController.displaySearchCourses(viewModel: .init())
        } else {
            _ = exploreViewController.view
            DispatchQueue.main.async {
                exploreViewController.displaySearchCourses(viewModel: .init())
            }
        }
    }

    private func selectNotificationsSection() {
        guard let currentViewControllers = self.currentTabBarController?.viewControllers,
              let navigationController = currentViewControllers[safe: self.tab.index] as? UINavigationController,
              let pager = navigationController.topViewController as? NotificationsPagerViewController else {
            return
        }

        if !pager.isViewLoaded,
           let sectionIndex = pager.sections.firstIndex(of: self.notificationsSection) {
            pager.startTabIndex = sectionIndex
        } else {
            pager.selectSection(self.notificationsSection)
        }
    }

    enum Tab: Equatable {
        case home
        case catalog(searchCourses: Bool = false)
        case profile
        case notifications

        var index: Int {
            switch self {
            case .home:
                return 0
            case .catalog:
                return 1
            case .profile:
                return 2
            case .notifications:
                return 3
            }
        }
    }
}
