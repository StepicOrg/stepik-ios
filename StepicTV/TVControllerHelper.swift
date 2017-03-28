//
//  TVControllerHelper.swift
//  Stepic
//
//  Created by Anton Kondrashov on 28/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

struct TVControllerHelper {
    static func getAuthController() -> SignInViewController? {
        return ControllerHelper.instantiateViewController(identifier: "Authorization") as? SignInViewController
    }
}
