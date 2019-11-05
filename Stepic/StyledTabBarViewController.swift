//
//  StyledTabBarViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

final class StyledTabBarViewController: UITabBarController {
    private let items = StepicApplicationsInfo.Modules.tabs?.compactMap { TabController(rawValue: $0)?.itemInfo } ?? []

    private var notificationsBadgeNumber: Int {
        get {
            if let tab = self.tabBar.items?.filter({ $0.tag == TabController.notifications.tag }).first {
                return Int(tab.badgeValue ?? "0") ?? 0
            }
            return 0
        }
        set {
            if let tab = self.tabBar.items?.filter({ $0.tag == TabController.notifications.tag }).first {
                tab.badgeValue = newValue > 0 ? "\(newValue)" : nil
                self.fixBadgePosition()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.mainDark
        self.tabBar.unselectedItemTintColor = UIColor(hex: 0xbabac1)
        self.tabBar.isTranslucent = false

        self.setViewControllers(self.items.map {
            let viewController = $0.controller
            viewController.tabBarItem = $0.makeTabBarItem()
            return viewController
        }, animated: false)
        self.fixBadgePosition()

        self.delegate = self

        if !AuthInfo.shared.isAuthorized {
            self.selectedIndex = 1
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didBadgeUpdate(systemNotification:)),
            name: .badgeUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didScreenRotate),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !DefaultsContainer.launch.didLaunch {
            DefaultsContainer.launch.didLaunch = true

            let onboardingViewController = ControllerHelper.instantiateViewController(
                identifier: "Onboarding",
                storyboardName: "Onboarding"
            )
            self.present(onboardingViewController, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Private API

    @objc
    private func didBadgeUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let value = userInfo["value"] as? Int else {
            return
        }

        self.notificationsBadgeNumber = value
    }

    @objc
    private func didScreenRotate() {
        self.fixBadgePosition()
    }

    private func fixBadgePosition() {
        for i in 1...items.count {
            if i >= tabBar.subviews.count { break }

            for badgeView in tabBar.subviews[i].subviews {
                if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                    badgeView.layer.transform = CATransform3DIdentity

                    if DeviceInfo.current.orientation.interface.isLandscape {
                        if DeviceInfo.current.isPlus {
                            badgeView.layer.transform = CATransform3DMakeTranslation(-2.0, 5.0, 1.0)
                        } else {
                            badgeView.layer.transform = CATransform3DMakeTranslation(1.0, 2.0, 1.0)
                        }
                    } else {
                        if DeviceInfo.current.isPad {
                            badgeView.layer.transform = CATransform3DMakeTranslation(1.0, 3.0, 1.0)
                        } else {
                            badgeView.layer.transform = CATransform3DMakeTranslation(-6.0, -1.0, 1.0)
                        }
                    }
                }
            }
        }
    }
}

extension StyledTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let selectedIndex = tabBarController.viewControllers?.index(of: viewController),
              let eventName = self.items[safe: selectedIndex]?.clickEventName else {
            return
        }

        AnalyticsReporter.reportEvent(eventName)
    }
}

private struct TabBarItemInfo {
    var title: String
    var controller: UIViewController
    var clickEventName: String
    var image: UIImage
    var tag: Int

    func makeTabBarItem() -> UITabBarItem {
        return UITabBarItem(title: self.title, image: self.image, tag: self.tag)
    }
}

private enum TabController: String {
    case profile = "Profile"
    case home = "Home"
    case notifications = "Notifications"
    case explore = "Catalog"

    var tag: Int {
        return self.hashValue
    }

    var itemInfo: TabBarItemInfo {
        switch self {
        case .profile:
            let viewController = ControllerHelper.instantiateViewController(
                identifier: "ProfileNavigation",
                storyboardName: "Main"
            )
            return TabBarItemInfo(
                title: NSLocalizedString("Profile", comment: ""),
                controller: viewController,
                clickEventName: AnalyticsEvents.Tabs.profileClicked,
                image: UIImage(named: "tab-profile").require(),
                tag: self.tag
            )
        case .home:
            let viewController = HomeAssembly().makeModule()
            let navigationViewController = StyledNavigationController(
                rootViewController: viewController
            )
            return TabBarItemInfo(
                title: NSLocalizedString("Home", comment: ""),
                controller: navigationViewController,
                clickEventName: AnalyticsEvents.Tabs.myCoursesClicked,
                image: UIImage(named: "tab-home").require(),
                tag: self.tag
            )
        case .notifications:
            let viewController = ControllerHelper.instantiateViewController(
                identifier: "NotificationsNavigation",
                storyboardName: "Main"
            )
            return TabBarItemInfo(
                title: NSLocalizedString("Notifications", comment: ""),
                controller: viewController,
                clickEventName: AnalyticsEvents.Tabs.notificationsClicked,
                image: UIImage(named: "tab-notifications").require(),
                tag: self.tag
            )
        case .explore:
            let viewController = ExploreAssembly().makeModule()
            let navigationViewController = StyledNavigationController(
                rootViewController: viewController
            )
            return TabBarItemInfo(
                title: NSLocalizedString("Catalog", comment: ""),
                controller: navigationViewController,
                clickEventName: AnalyticsEvents.Tabs.catalogClicked,
                image: UIImage(named: "tab-explore").require(),
                tag: self.tag
            )
        }
    }
}
