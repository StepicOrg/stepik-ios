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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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

    var itemInfo: TabBarItemInfo {
        switch self {
        case .myCourses:
            return TabBarItemInfo(title: NSLocalizedString("MyCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "MyCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.myCoursesClicked, image: #imageLiteral(resourceName: "tab-my-courses"))
        case .findCourses:
            return TabBarItemInfo(title: NSLocalizedString("FindCourses", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "FindCoursesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.findCoursesClicked, image: #imageLiteral(resourceName: "tab-find-courses"))
        case .certificates:
            return TabBarItemInfo(title: NSLocalizedString("Certificates", comment: ""), controller: ControllerHelper.instantiateViewController(identifier: "CertificatesNavigation", storyboardName: "Main"), clickEventName: AnalyticsEvents.Tabs.certificatesClicked, image: #imageLiteral(resourceName: "tab-certificates"))
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
