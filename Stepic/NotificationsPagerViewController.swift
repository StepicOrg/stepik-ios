//
//  NotificationsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class NotificationsPagerViewController: TabmanViewController {
    var sections: [(NotificationsSection, String)] = [
        (.all, "All"),
        (.learning, "Learning"),
        (.comments, "Comments"),
        (.reviews, "Reviews"),
        (.teaching, "Teaching"),
        (.other, "Other")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        self.bar.appearance = TabmanBar.Appearance({ appearance in
            appearance.indicator.color = UIColor(hex: 0x535366)
            appearance.state.selectedColor = UIColor(hex: 0x535366)
            appearance.state.color = UIColor(hex: 0x535366)

            appearance.text.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)

            appearance.layout.interItemSpacing = 30.0
            appearance.style.background = .solid(color: UIColor(hex: 0xf6f6f6))
        })
        self.bar.items = sections.map { Item(title: $0.1) }
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

extension NotificationsPagerViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return sections.count
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        let vc = ControllerHelper.instantiateViewController(identifier: "NotificationsViewController", storyboardName: "Notifications") as! NotificationsViewController
        vc.section = sections[index].0
        return vc
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension NotificationsPagerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigation = self.navigationController as? StyledNavigationViewController else {
            return
        }

        navigation.animateShadowChange(for: self)
    }
}
