//
//  SourcelessRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class SourcelessRouter {
    var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    var currentTabBarController: UITabBarController? {
        return self.window?.rootViewController as? UITabBarController
    }

    var currentNavigation: UINavigationController? {
        guard let tabController = self.currentTabBarController else {
            return nil
        }

        let count = tabController.viewControllers?.count ?? 0
        let index = tabController.selectedIndex

        if index < count {
            return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
        } else {
            return tabController.viewControllers?[0] as? UINavigationController
        }
    }
}
