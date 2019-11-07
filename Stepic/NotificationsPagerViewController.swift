//
//  NotificationsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class NotificationsPagerViewController: PagerController, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()

    var sections: [NotificationsSection] = [.all, .learning, .comments, .reviews, .teaching, .other]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("Notifications", comment: "")

        self.dataSource = self
        self.setUpTabs()

        self.registerPlaceholder(placeholder: StepikPlaceholder(.login, action: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
        }), for: .anonymous)

        if !AuthInfo.shared.isAuthorized {
            self.showPlaceholder(for: .anonymous)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if AuthInfo.shared.isAuthorized {
            self.isPlaceholderShown = false
        } else {
            self.showPlaceholder(for: .anonymous)
        }

        if let styledNavigationController = self.navigationController as? StyledNavigationController {
            styledNavigationController.changeShadowViewAlpha(AuthInfo.shared.isAuthorized ? 0.0 : 1.0, sender: self)
        }
    }

    private func setUpTabs() {
        self.tabHeight = 44.0
        self.indicatorHeight = 1.5
        self.centerCurrentTab = true
        self.indicatorColor = UIColor.mainDark
        self.selectedTabTextColor = UIColor.mainDark
        self.tabsTextColor = UIColor.mainDark
        self.tabsTextFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        self.tabsViewBackgroundColor = UIColor.mainLight
    }

    func selectSection(_ notificationSection: NotificationsSection) {
        if let index = self.sections.index(of: notificationSection) {
            self.selectTabAtIndex(index)
        }
    }
}

extension NotificationsPagerViewController: PagerDataSource {
    func numberOfTabs(_ pager: PagerController) -> Int {
        return self.sections.count
    }

    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        label.text = sections[index].localizedName

        label.sizeToFit()

        return label
    }

    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        guard let notificationsViewController = ControllerHelper.instantiateViewController(
            identifier: "NotificationsViewController",
            storyboardName: "Notifications"
        ) as? NotificationsViewController else {
            fatalError("Failed instantiate NotificationsViewController via storyboard")
        }

        notificationsViewController.section = self.sections[index]

        return notificationsViewController
    }
}

extension NotificationsPagerViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return .init(shadowViewAlpha: AuthInfo.shared.isAuthorized ? 0.0 : 1.0)
    }
}
