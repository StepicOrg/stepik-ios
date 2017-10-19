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

        delegate = self

        if !AuthInfo.shared.isAuthorized {
            selectedIndex = 1
        }
    }

    func getEventNameForTabIndex(index: Int) -> String? {
        guard index < items.count else {
            return nil
        }
        return items[index].clickEventName
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
    case notifications = "Notifications"

    var itemInfo: TabBarItemInfo {
        switch self {
        case .myCourses:
            return TabBarItemInfo(title: NSLocalizedString("MyCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "MyCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.myCoursesClicked, image: #imageLiteral(resourceName: "tab-my-courses"))
        case .findCourses:
            return TabBarItemInfo(title: NSLocalizedString("FindCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "FindCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.findCoursesClicked, image: #imageLiteral(resourceName: "tab-find-courses"))
        case .certificates:
            return TabBarItemInfo(title: NSLocalizedString("Certificates", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "CertificatesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.certificatesClicked, image: #imageLiteral(resourceName: "tab-certificates"))
        case .profile:
            return TabBarItemInfo(title: NSLocalizedString("Profile", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "ProfileNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.profileClicked, image: #imageLiteral(resourceName: "tab-profile"))
        case .notifications:
            return TabBarItemInfo(title: NSLocalizedString("Notifications", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "NotificationsNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.notificationsClicked, image: #imageLiteral(resourceName: "notifications"))
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
