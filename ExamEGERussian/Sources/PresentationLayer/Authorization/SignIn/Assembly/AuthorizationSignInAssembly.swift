//
//  AuthorizationSignInAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthorizationSignInAssembly: class {
    func module(navigationController: UINavigationController, router: AuthorizationSignInRouter?) -> UIViewController
    func router(navigationController: UINavigationController) -> AuthorizationSignInRouter
}

extension AuthorizationSignInAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        return module(navigationController: navigationController, router: nil)
    }
}
