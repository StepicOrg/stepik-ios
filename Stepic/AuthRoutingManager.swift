//
//  AuthRoutingManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AuthRoutingManager {
    func routeFrom(controller: UIViewController, success: (() -> Void)?, cancel: (() -> Void)?) {
        if let vc = ControllerHelper.getAuthController() as? AuthNavigationViewController {
            vc.success = success
            vc.cancel = cancel
            vc.source = controller
            controller.present(vc, animated: true, completion: nil)
        }
    }
}
