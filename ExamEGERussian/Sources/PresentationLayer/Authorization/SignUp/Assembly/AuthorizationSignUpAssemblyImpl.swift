//
//  AuthorizationSignUpAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthorizationSignUpAssemblyImpl: BaseAssembly, AuthorizationSignUpAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        let vc = AuthorizationSignUpViewController.make()
        vc.presenter = AuthorizationSignUpPresenter(authAPI: serviceFactory.authAPI, stepicsAPI: serviceFactory.stepicsAPI, notificationStatusesAPI: serviceFactory.notificationStatusesAPI, view: vc)
        vc.delegate = AuthorizationSignUpRouterImpl(assemblyFactory: assemblyFactory, navigationController: navigationController)

        return vc
    }
}
