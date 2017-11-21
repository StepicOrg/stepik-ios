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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            let inset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 8.0 : 6.0
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
                switch UIDevice.current.orientation {
                case .landscapeLeft, .landscapeRight:
                    // Using default tabbar in landscape
                    showDefaultTitle(for: item)
                default:
                    if UIDevice.current.userInterfaceIdiom == .pad {
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
        (1...items.count).forEach {
            for badgeView in tabBar.subviews[$0].subviews {
                if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                    badgeView.layer.transform = CATransform3DIdentity
                    badgeView.layer.transform = CATransform3DMakeTranslation(-5.0, 1.0, 1.0)
                }
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.updateTitlesForTabBarItems()
        self.fixBadgePosition()
    }
}

struct TabBarItemInfo {
    var clickEventName: String
    var title: String
    var controller: UIViewController
    var image: UIImage

    init(title: String, controller: UIViewController, clickEventName: String, image: UIImage) {
        self.title = title
        self.controller = controller
        self.clickEventName = clickEventName
        self.image = image
    }

    func buildItem() -> UITabBarItem {
        return UITabBarItem(title: title, image: image, tag: 0)
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

    var itemInfo: TabBarItemInfo {
        switch self {
        case .myCourses:
            return TabBarItemInfo(title: NSLocalizedString("MyCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "MyCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.myCoursesClicked, image: #imageLiteral(resourceName: "tab-home"))
        case .findCourses:
            return TabBarItemInfo(title: NSLocalizedString("FindCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "FindCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.findCoursesClicked, image: #imageLiteral(resourceName: "tab-explore"))
        case .certificates:
            return TabBarItemInfo(title: NSLocalizedString("Certificates", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "CertificatesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.certificatesClicked, image: #imageLiteral(resourceName: "tab-certificates"))
        case .profile:
            return TabBarItemInfo(title: NSLocalizedString("Profile", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "ProfileNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.profileClicked, image: #imageLiteral(resourceName: "tab-profile"))
        case .home:
            return TabBarItemInfo(title: NSLocalizedString("Home", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "HomeNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.profileClicked, image: #imageLiteral(resourceName: "tab-home"))
        case .notifications:
            return TabBarItemInfo(title: NSLocalizedString("Notifications", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "NotificationsNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.notificationsClicked, image: #imageLiteral(resourceName: "tab-notifications"))
        case .explore:
            return TabBarItemInfo(title: NSLocalizedString("Catalog", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "ExploreNavigation", storyboardName: "Explore"), clickEventName: AnalyticsEvents.Tabs.catalogClicked, image: #imageLiteral(resourceName: "tab-explore"))
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
