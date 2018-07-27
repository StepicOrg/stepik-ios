//
//  AuthorizationSignUpRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit.UINavigationController

protocol AuthSignUpRouter: RouterDismissable {
    var navigationController: UINavigationController? { get }
}

final class AuthSignUpRouterImpl: BaseRouter, AuthSignUpRouter {
}
