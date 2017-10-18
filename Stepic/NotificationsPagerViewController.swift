//
//  NotificationsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationsPagerViewController: PagerController {
    var sections: [NotificationsSection] = [
        .all, .learning, .comments, .reviews, .teaching, .other
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Notifications", comment: "")

        self.dataSource = self
        setUpTabs()
    }
    
    fileprivate func setUpTabs() {
        tabHeight = 44.0
        indicatorHeight = 1.5
        centerCurrentTab = true
        indicatorColor = UIColor.mainDark
        selectedTabTextColor = UIColor.mainDark
        tabsTextColor = UIColor.mainDark
        tabsTextFont = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
        tabsViewBackgroundColor = UIColor.mainLight
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }
}

extension NotificationsPagerViewController: PagerDataSource {
    func numberOfTabs(_ pager: PagerController) -> Int {
        return sections.count
    }
    
    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
        label.text = sections[index].localizedName
        label.sizeToFit()
        return label
    }
    
    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        let vc = ControllerHelper.instantiateViewController(identifier: "NotificationsViewController", storyboardName: "Notifications") as! NotificationsViewController
        vc.section = sections[index]
        return vc
    }
}

extension NotificationsPagerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigation = self.navigationController as? StyledNavigationViewController else {
            return
        }

        navigation.changeShadowAlpha(0)
    }
}
