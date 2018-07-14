//
//  AuthorizationAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthorizationAssemblyImpl: BaseAssembly, AuthorizationAssembly {
    func module() -> UINavigationController {
        let controller = EmptyAuthViewController()
        let navigationController = ClearNavigationViewController(rootViewController: controller)

        return navigationController
    }
}
