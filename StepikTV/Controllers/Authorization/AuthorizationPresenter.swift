//
//  AuthorizationPresenter.swift
//  StepikTV
//
//  Created by Anton Kondrashov on 17/12/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class AuthorizationPresenter {

    var authAPI: AuthAPI
    var stepicsAPI: StepicsAPI

    private weak var view: AuthorizationView?
    private var alert: AuthorizationAlert?

    init(view: AuthorizationView, authAPI: AuthAPI, stepicsAPI: StepicsAPI) {
        self.view = view
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
    }

    func checkForCachedUser() {
        guard AuthInfo.shared.isAuthorized, let user = AuthInfo.shared.user else {
            view?.showNoProfile()
            return
        }

        view?.showProfile(for: user)
    }

    func registerAction() {
        alert = AuthorizationAlert(type: .registration)
        alert?.successCompletion = successCompletion(answer:)

        view?.show(alert: alert!)
    }

    func loginAction() {
        alert = AuthorizationAlert(type: .login)
        alert?.successCompletion = successCompletion(answer:)

        view?.show(alert: alert!)
    }

    func remoteLoginAction() {

    }

    func logoutAction() {
        AuthInfo.shared.token = nil

        view?.showNoProfile()
    }

    func successCompletion(answer: AuthorizationAlert.Answer) {
        switch answer {
        case .login(let email, let password):
          login(email: email, password: password)
        case .registration(let name, let email, let password):
          register(name: name, email: email, password: password)
        }
    }

    private func login(email: String, password: String) {
        authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
          AuthInfo.shared.token = token
          AuthInfo.shared.authorizationType = authorizationType

          return self.stepicsAPI.retrieveCurrentUser()
          }.then { user -> Void in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            NotificationCenter.default.post(name: .userLoggedIn, object: self)

            self.view?.showProfile(for: user)
          }.catch { _ in
            //proccess error
        }
    }

    private func register(name: String, email: String, password: String) {
        checkToken().then { () -> Promise<()> in
          self.authAPI.signUpWithAccount(firstname: name, lastname: " ", email: email, password: password)
          }.then { _ -> Promise<(StepicToken, AuthorizationType)> in
            self.authAPI.signInWithAccount(email: email, password: password)
          }.then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            return self.stepicsAPI.retrieveCurrentUser()
          }.then { user -> Void in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            NotificationCenter.default.post(name: .userLoggedIn, object: self)

            self.view?.showProfile(for: user)
          }.catch { _ in
            //proccess error
        }
    }
}
