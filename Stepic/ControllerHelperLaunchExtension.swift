//
//  ControllerHelperLaunchExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

extension ControllerHelper {
    static func getAuthController() -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthNavigation")

        return vc
    }
}
