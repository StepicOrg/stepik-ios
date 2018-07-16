//
//  AuthRouter.swift
//  Stepic
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthRouterDelegate: class {
    func authRouterWillStartDismiss(_ authRouter: AuthRouter, withState state: AuthRouter.State)
    func authRouterDidEndDismiss(_ authRouter: AuthRouter, withState state: AuthRouter.State)
}

final class AuthRouter {
    enum State {
        case success
        case cancel
    }

    private enum Controller {
        case social
        case email(email: String?)
        case registration
    }

    // MARK: - Instance Properties

    let assembly: AuthAssembly
    private weak var navigationController: UINavigationController?
    private weak var delegate: AuthRouterDelegate?

    // MARK: - Init

    init(navigationController: UINavigationController, delegate: AuthRouterDelegate,
         assembly: AuthAssembly) {
        self.navigationController = navigationController
        self.delegate = delegate
        self.assembly = assembly
    }

    // MARK: Public API

    func showEmail(_ email: String?) {
        route(from: .social, to: .email(email: email))
    }

    // MARK: Private API

    private func dismiss(with state: State) {
        delegate?.authRouterWillStartDismiss(self, withState: state)
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.authRouterDidEndDismiss(strongSelf, withState: state)
        })
    }

    private func route(from fromController: Controller, to toController: Controller?) {
        guard let navigationController = navigationController else { return print("navigationController doesn't exists") }

        if toController == nil {
            // Close action
            switch fromController {
            case .registration:
                navigationController.popViewController(animated: true)
            default:
                dismiss(with: .cancel)
            }
            return
        }

        var vcs = navigationController.viewControllers

        switch toController! {
        case .registration:
            // Push registration controller
            let vc = assembly.registrationModule(delegate: self)
            navigationController.pushViewController(vc, animated: true)
        case .email(let email):
            // Replace top view controller
            let vc = assembly.emailModule(delegate: self, email: email)
            vcs[vcs.count - 1] = vc
            navigationController.setViewControllers(vcs, animated: true)
        case .social:
            // Replace top view controller
            let vc = assembly.socialModule(delegate: self)
            vcs[vcs.count - 1] = vc
            navigationController.setViewControllers(vcs, animated: true)
        }
    }
}

// MARK: - AuthRouter: EmailAuthViewControllerDelegate -

extension AuthRouter: EmailAuthViewControllerDelegate {
    func emailAuthViewControllerOnSuccess(_ emailAuthViewController: EmailAuthViewController) {
        dismiss(with: .success)
    }

    func emailAuthViewControllerOnClose(_ emailAuthViewController: EmailAuthViewController) {
        route(from: .email(email: nil), to: nil)
    }

    func emailAuthViewControllerOnSignInWithSocial(_ emailAuthViewController: EmailAuthViewController) {
        route(from: .email(email: nil), to: .social)
    }

    func emailAuthViewControllerOnSignUp(_ emailAuthViewController: EmailAuthViewController) {
        route(from: .email(email: nil), to: .registration)
    }
}

// MARK: - AuthRouter: SocialAuthViewControllerDelegate -

extension AuthRouter: SocialAuthViewControllerDelegate {
    func socialAuthViewControllerOnSuccess(_ socialAuthViewController: SocialAuthViewController) {
        dismiss(with: .success)
    }

    func socialAuthViewControllerOnClose(_ socialAuthViewController: SocialAuthViewController) {
        route(from: .social, to: nil)
    }

    func socialAuthViewControllerOnSignInWithEmail(_ socialAuthViewController: SocialAuthViewController) {
        route(from: .social, to: .email(email: nil))
    }

    func socialAuthViewControllerOnSignUp(_ socialAuthViewController: SocialAuthViewController) {
        route(from: .social, to: .registration)
    }
}

// MARK: - AuthRouter: RegistrationViewControllerDelegate  -

extension AuthRouter: RegistrationViewControllerDelegate {
    func registrationViewControllerOnSuccess(_ registrationViewController: RegistrationViewController) {
        dismiss(with: .success)
    }

    func registrationViewControllerOnClose(_ registrationViewController: RegistrationViewController) {
        route(from: .registration, to: nil)
    }
}
