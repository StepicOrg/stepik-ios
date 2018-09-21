//
//  SourcelessRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class SourcelessRouter {
    var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    var currentNavigation: UINavigationController? {
        guard let tabController = currentTabBarController else {
            return nil
        }
        let cnt = tabController.viewControllers?.count ?? 0
        let index = tabController.selectedIndex
        if index < cnt {
            return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
        } else {
            return tabController.viewControllers?[0] as? UINavigationController
        }
    }

    var currentTabBarController: UITabBarController? {
        return window?.rootViewController as? UITabBarController
    }
}
