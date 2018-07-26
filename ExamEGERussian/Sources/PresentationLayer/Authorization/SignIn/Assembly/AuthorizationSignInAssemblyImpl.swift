//
//  AuthorizationSignInAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthorizationSignInAssemblyImpl: BaseAssembly, AuthorizationSignInAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        let controller = AuthorizationSignInViewController()
        controller.presenter = EmailAuthPresenter(
            authAPI: serviceFactory.authAPI,
            stepicsAPI: serviceFactory.stepicsAPI,
            notificationStatusesAPI: serviceFactory.notificationStatusesAPI,
            view: controller
        )

        return controller
    }
}
