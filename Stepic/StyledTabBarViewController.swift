//
//  StyledTabBarViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StyledTabBarViewController: UITabBarController {

    let items = StepicApplicationsInfo.Modules.tabs?.flatMap { TabController(rawValue: $0)?.itemInfo } ?? []

    var notificationsBadgeNumber: Int {
        get {
            if let tab = tabBar.items?.filter({ $0.tag == TabController.notifications.tag }).first {
                return Int(tab.badgeValue ?? "0") ?? 0
            }
            return 0
        }
        set {
            if let tab = tabBar.items?.filter({ $0.tag == TabController.notifications.tag }).first {
                tab.badgeValue = newValue > 0 ? "\(newValue)" : nil
                fixBadgePosition()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = UIColor.mainDark
        tabBar.isTranslucent = false

        self.setViewControllers(items.map {
            let vc = $0.controller
            vc.tabBarItem = $0.buildItem()
            return vc
        }, animated: false)
        self.updateTitlesForTabBarItems()

        delegate = self

        if !AuthInfo.shared.isAuthorized {
            selectedIndex = 1
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.didBadgeUpdate(systemNotification:)), name: .badgeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didScreenRotate), name: .UIDeviceOrientationDidChange, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !DefaultsContainer.launch.didLaunch {
            AnalyticsReporter.reportEvent(AnalyticsEvents.App.firstLaunch, parameters: nil)
            DefaultsContainer.launch.didLaunch = true

            let onboardingVC = ControllerHelper.instantiateViewController(identifier: "Onboarding", storyboardName: "Onboarding")
            present(onboardingVC, animated: true, completion: nil)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didBadgeUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
            let value = userInfo["value"] as? Int else {
                return
        }

        self.notificationsBadgeNumber = value
    }

    @objc func didScreenRotate() {
        self.updateTitlesForTabBarItems()
        self.fixBadgePosition()
    }

    func getEventNameForTabIndex(index: Int) -> String? {
        guard index < items.count else {
            return nil
        }
        return items[index].clickEventName
    }

    private func updateTitlesForTabBarItems() {
        func hideTitle(for item: UITabBarItem) {
            let inset: CGFloat = DeviceInfo.current.isPad ? 8.0 : 6.0
            item.imageInsets = UIEdgeInsets(top: inset, left: 0, bottom: -inset, right: 0)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: CGFloat.greatestFiniteMagnitude)
        }

        func showDefaultTitle(for item: UITabBarItem) {
            item.imageInsets = UIEdgeInsets.zero
            item.titlePositionAdjustment = UIOffset.zero
        }

        self.tabBar.items?.forEach { item in
            if #available(iOS 11.0, *) {
                // For new tabbar in iOS 11.0+
                if DeviceInfo.current.orientation.interface.isLandscape {
                    // Using default tabbar in landscape
                    showDefaultTitle(for: item)
                } else {
                    if DeviceInfo.current.isPad {
                        // Using default tabbar on iPads in both orientations
                        showDefaultTitle(for: item)
                    } else {
                        // Using tabbar w/o titles in other cases
                        hideTitle(for: item)
                    }
                }
            } else {
                // Using tabbar w/o titles if iOS version < 11.0
                hideTitle(for: item)
            }
        }
    }

    private func fixBadgePosition() {
        for i in 1...items.count {
            if i >= tabBar.subviews.count { break }

            for badgeView in tabBar.subviews[i].subviews {
                if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                    badgeView.layer.transform = CATransform3DIdentity

                    if #available(iOS 11.0, *) {
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
                                badgeView.layer.transform = CATransform3DMakeTranslation(-5.0, 3.0, 1.0)
                            }
                        }
                    } else {
                        if DeviceInfo.current.orientation.interface.isLandscape {
                            if DeviceInfo.current.isPlus {
                                badgeView.layer.transform = CATransform3DMakeTranslation(-5.0, 3.0, 1.0)
                            } else {
                                badgeView.layer.transform = CATransform3DMakeTranslation(-5.0, 3.0, 1.0)
                            }
                        } else {
                            if DeviceInfo.current.isPad {
                                badgeView.layer.transform = CATransform3DMakeTranslation(-5.0, 3.0, 1.0)
                            } else {
                                badgeView.layer.transform = CATransform3DMakeTranslation(-5.0, 3.0, 1.0)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TabBarItemInfo {
    var title: String
    var controller: UIViewController
    var clickEventName: String
    var image: UIImage
    var tag: Int

    func buildItem() -> UITabBarItem {
        return UITabBarItem(title: title, image: image, tag: tag)
    }
}

enum TabController: String {
    case myCourses = "MyCourses"
    case findCourses = "FindCourses"
    case certificates = "Certificates"
    case profile = "Profile"
    case home = "Home"
    case notifications = "Notifications"
    case explore = "Catalog"

    var tag: Int {
        return self.hashValue
    }

    var itemInfo: TabBarItemInfo {
        switch self {
        case .myCourses:
            return TabBarItemInfo(title: NSLocalizedString("MyCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "MyCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.myCoursesClicked, image: #imageLiteral(resourceName: "tab-home"), tag: self.tag)
        case .findCourses:
            return TabBarItemInfo(title: NSLocalizedString("FindCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "FindCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.findCoursesClicked, image: #imageLiteral(resourceName: "tab-explore"), tag: self.tag)
        case .certificates:
            return TabBarItemInfo(title: NSLocalizedString("Certificates", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "CertificatesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.certificatesClicked, image: #imageLiteral(resourceName: "tab-certificates"), tag: self.tag)
        case .profile:
            return TabBarItemInfo(title: NSLocalizedString("Profile", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "ProfileNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.profileClicked, image: #imageLiteral(resourceName: "tab-profile"), tag: self.tag)
        case .home:
            return TabBarItemInfo(title: NSLocalizedString("Home", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "HomeNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.profileClicked, image: #imageLiteral(resourceName: "tab-home"), tag: self.tag)
        case .notifications:
            return TabBarItemInfo(title: NSLocalizedString("Notifications", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "NotificationsNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.notificationsClicked, image: #imageLiteral(resourceName: "tab-notifications"), tag: self.tag)
        case .explore:
            return TabBarItemInfo(title: NSLocalizedString("Catalog", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "ExploreNavigation", storyboardName: "Explore"), clickEventName: AnalyticsEvents.Tabs.catalogClicked, image: #imageLiteral(resourceName: "tab-explore"), tag: self.tag)
        }
    }
}

extension StyledTabBarViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let selectedIndex = tabBarController.viewControllers?.index(of: viewController) {
            if let eventName = getEventNameForTabIndex(index: selectedIndex) {
                AnalyticsReporter.reportEvent(eventName, parameters: nil)
            }
        }
    }
}
