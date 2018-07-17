//
//  MainViewPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class MainViewPresenterImpl: MainViewPresenter {

    // MARK: Instance Properties

    var router: MainViewRouter
    private weak var view: MainView?
    private let userRegistrationService: UserRegistrationService

    private var isLoggedIn: Bool {
        return AuthInfo.shared.isAuthorized && AuthInfo.shared.isFake != .yes
    }

    // MARK: - Init

    init(view: MainView, router: MainViewRouter, userRegistrationService: UserRegistrationService) {
        self.view = view
        self.router = router
        self.userRegistrationService = userRegistrationService
    }

    // MARK: - MainViewPresenter

    func viewDidLoad() {
        checkAccessToken()
    }

    func viewWillAppear() {
        update()
    }

    func rightBarButtonPressed() {
        if isLoggedIn {
            logout()
        } else {
            router.showAuthorizationModule()
        }
    }

    func titleForRightBarButtonItem() -> String {
        return isLoggedIn
            ? NSLocalizedString("Logout", comment: "")
            : NSLocalizedString("SignIn", comment: "")
    }

    // MARK: - Private API

    private func logout() {
        AuthInfo.shared.token = nil
        AuthInfo.shared.isFake = .notExist
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.update()
        }
    }

    private func update() {
        UIView.animate(withDuration: 0.33) { [weak self] in
            guard let `self` = self else { return }
            self.view?.setTitle(String(describing: MainView.self))
            self.view?.setRightBarButtonItemTitle(self.titleForRightBarButtonItem())
            self.view?.setGreetingText(self.greetingText())
        }
    }

    private func greetingText() -> String {
        guard AuthInfo.shared.isAuthorized,
            let user = AuthInfo.shared.user else {
            return "Please, sign in into your account"
        }

        return AuthInfo.shared.isFake == .yes
            ? "Fake user with id: \(user.id)"
            : "\(user.firstName) \(user.lastName)"
    }

    private func checkAccessToken() {
        checkToken().done { [weak self] in
            if !AuthInfo.shared.isAuthorized {
                self?.userRegistrationService
                    .registerNewUser()
                    .done { [weak self] _ in
                        self?.update()
                    }
                    .catch { print($0) }
            }
        }.catch { print($0) }
    }
}
