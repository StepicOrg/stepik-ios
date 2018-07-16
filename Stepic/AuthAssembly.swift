//
//  AuthAssembly.swift
//  Stepic
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthAssembly {
    func registrationModule(delegate: RegistrationViewControllerDelegate) -> RegistrationViewController
    func registrationPresenter(view: RegistrationView) -> RegistrationPresenter
    func emailModule(delegate: EmailAuthViewControllerDelegate, email: String?) -> EmailAuthViewController
    func emailPresenter(view: EmailAuthView) -> EmailAuthPresenter
    func socialModule(delegate: SocialAuthViewControllerDelegate) -> SocialAuthViewController
    func socialPresenter(view: SocialAuthView) -> SocialAuthPresenter
}

final class AuthAssemblyImpl: AuthAssembly {

    private let authAPI: AuthAPI
    private let stepicsAPI: StepicsAPI
    private let notificationStatusesAPI: NotificationStatusesAPI

    init(authAPI: AuthAPI = ApiDataDownloader.auth,
         stepicsAPI: StepicsAPI = ApiDataDownloader.stepics,
         notificationStatusesAPI: NotificationStatusesAPI = NotificationStatusesAPI()) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI
    }

    func registrationModule(delegate: RegistrationViewControllerDelegate) -> RegistrationViewController {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "Registration", storyboardName: "Auth") as? RegistrationViewController else { fatalError("Failed to instantiate RegistrationViewController") }
        vc.presenter = registrationPresenter(view: vc)
        vc.delegate = delegate

        return vc
    }

    func registrationPresenter(view: RegistrationView) -> RegistrationPresenter {
        return RegistrationPresenter(authAPI: authAPI, stepicsAPI: stepicsAPI, notificationStatusesAPI: notificationStatusesAPI, view: view)
    }

    func emailModule(delegate: EmailAuthViewControllerDelegate, email: String?) -> EmailAuthViewController {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "EmailAuth", storyboardName: "Auth") as? EmailAuthViewController else { fatalError("Failed to instantiate EmailAuthViewController") }
        vc.presenter = emailPresenter(view: vc)
        vc.delegate = delegate
        vc.prefilledEmail = email

        return vc
    }

    func emailPresenter(view: EmailAuthView) -> EmailAuthPresenter {
        return EmailAuthPresenter(authAPI: authAPI, stepicsAPI: stepicsAPI, notificationStatusesAPI: notificationStatusesAPI, view: view)
    }

    func socialModule(delegate: SocialAuthViewControllerDelegate) -> SocialAuthViewController {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "SocialAuth", storyboardName: "Auth") as? SocialAuthViewController else { fatalError("Failed to instantiate SocialAuthViewController") }
        vc.presenter = socialPresenter(view: vc)
        vc.delegate = delegate

        return vc
    }

    func socialPresenter(view: SocialAuthView) -> SocialAuthPresenter {
        return SocialAuthPresenter(authAPI: authAPI, stepicsAPI: stepicsAPI, notificationStatusesAPI: notificationStatusesAPI, view: view)
    }
}
