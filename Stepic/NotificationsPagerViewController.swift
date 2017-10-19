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

    lazy var placeholderView: UIView = {
        let v = PlaceholderView()
        self.view.addSubview(v)
        v.align(toView: self.view)
        v.delegate = self
        v.datasource = self
        v.backgroundColor = UIColor.groupTableViewBackground
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Notifications", comment: "")
        
        self.dataSource = self
        setUpTabs()
        
        if !AuthInfo.shared.isAuthorized {
            placeholderView.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        placeholderView.isHidden = AuthInfo.shared.isAuthorized
        updateNavigationControllerShadow(show: !AuthInfo.shared.isAuthorized)
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
    fileprivate func updateNavigationControllerShadow(show: Bool) {
        guard let navigation = self.navigationController as? StyledNavigationViewController else {
            return
        }

        navigation.changeShadowAlpha(!show ? 0 : 1)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if AuthInfo.shared.isAuthorized {
            // When user is not authorized we will use placeholder
            updateNavigationControllerShadow(show: false)
        }
    }
}

extension NotificationsPagerViewController: PlaceholderViewDataSource {
    func placeholderImage() -> UIImage? {
        return Images.placeholders.anonymous
    }
    
    func placeholderButtonTitle() -> String? {
        return NSLocalizedString("SignIn", comment: "")
    }
    
    func placeholderDescription() -> String? {
        return NSLocalizedString("SignInToHaveNotifications", comment: "")
    }
    
    func placeholderStyle() -> PlaceholderStyle {
        var style = stepicPlaceholderStyle
        style.button.backgroundColor = .clear
        style.title.textColor = UIColor.darkGray
        return style
    }
    
    func placeholderTitle() -> String? {
        return NSLocalizedString("AnonymousNotificationsTitle", comment: "")
    }
}

extension NotificationsPagerViewController: PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        let vc = ControllerHelper.getAuthController()
        self.present(vc, animated: true, completion: nil)
    }
}
