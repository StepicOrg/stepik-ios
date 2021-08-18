//
//  ControllerHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 10.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

enum ControllerHelper {
    static func getTopViewController() -> UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController

        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }

        return topViewController
    }

    static func getAuthController() -> UIViewController {
        guard let viewController = self.instantiateViewController(
            identifier: "AuthNavigation",
            storyboardName: "Auth"
        ) as? AuthNavigationViewController else {
            fatalError("Unable to initialize AuthNavigationViewController via storyboard")
        }

        return viewController
    }

    static func instantiateViewController(
        identifier id: String,
        storyboardName: String = "Main"
    ) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
}
