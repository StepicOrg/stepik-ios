//
//  AuthRoutingManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthRoutingManager {
    func routeFrom(controller: UIViewController, success: (() -> Void)?, cancel: (() -> Void)?) {
        if let viewController = ControllerHelper.getAuthController() as? AuthNavigationViewController {
            viewController.success = success
            viewController.cancel = cancel
            viewController.source = controller
            viewController.modalPresentationStyle = .fullScreen
            controller.present(viewController, animated: true, completion: nil)
        }
    }
}
