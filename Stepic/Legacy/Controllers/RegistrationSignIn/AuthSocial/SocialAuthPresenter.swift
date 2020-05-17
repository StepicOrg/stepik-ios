//
//  SocialAuthPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

struct SocialProviderViewData {
    let image: UIImage!
    let name: String
    let id: Int // id in SocialProvider
}

protocol SocialAuthView: AnyObject {
    var state: SocialAuthState { get set }

    func set(providers: [SocialProviderViewData])
    func update(with result: SocialAuthResult)

    func presentWebController(with url: URL)
    func dismissWebController()
}

enum SocialAuthResult {
    case success, error, existingEmail(email: String), noEmail, badConnection
}

enum SocialAuthState {
    case normal, loading
}

final class SocialAuthPresenter {
    weak var view: SocialAuthView?

    private let stepicsAPI: StepicsAPI
    private let authAPI: AuthAPI
    private let notificationStatusesAPI: NotificationStatusesAPI
    private let analytics: Analytics

    var pendingAuthProviderInfo: SocialProviderInfo?

    var socialAuthHeaderString: String { NSLocalizedString("SignInTitleSocial", comment: "") }

    init(
        authAPI: AuthAPI,
        stepicsAPI: StepicsAPI,
        notificationStatusesAPI: NotificationStatusesAPI,
        analytics: Analytics,
        view: SocialAuthView
    ) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI
        self.analytics = analytics
        self.view = view

        // TODO: create NSNotification.Name extension
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didAuthCodeReceive(_:)),
            name: NSNotification.Name(rawValue: "ReceivedAuthorizationCodeNotification"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func update() {
        let providersInfo = SocialProvider.allCases.map {
            SocialProviderViewData(image: $0.info.image, name: $0.name, id: $0.rawValue)
        }
        view?.set(providers: providersInfo)
    }

    func logIn(with providerId: Int) {
        guard let providerInfo = SocialProvider(rawValue: providerId)?.info else {
            print("social auth: provider with id = \(providerId) not found")
            self.view?.update(with: .error)
            return
        }

        self.pendingAuthProviderInfo = providerInfo

        guard let SDKProvider = providerInfo.socialSDKProvider else {
            view?.presentWebController(with: providerInfo.registerURL)
            return
        }

        if let SDKProvider = SDKProvider as? VKSocialSDKProvider,
           let viewDelegate = view as? VKSocialSDKProviderDelegate {
            SDKProvider.delegate = viewDelegate
        }

        SDKProvider.getAccessInfo().then { socialToken, email -> Promise<(StepikToken, AuthorizationType)> in
            self.authAPI.signUpWithToken(socialToken: socialToken, email: email, provider: SDKProvider.name)
        }.then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationsRegistrationService().renewDeviceToken()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            if user.didJustRegister {
                self.analytics.send(.signUpSucceeded(source: .social(providerInfo)))
            } else {
                self.analytics.send(.signInSucceeded(source: .social(providerInfo)))
            }

            self.pendingAuthProviderInfo = nil
            self.view?.update(with: .success)

            return self.notificationStatusesAPI.retrieve()
        }.done { result in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { error in
            switch error {
            case is SocialSDKError:
                print("social auth: error while social auth")
                self.view?.update(with: .error)
            case is NetworkError:
                print("social auth: successfully signed in, but could not get user")
                self.analytics.send(.signInSucceeded(source: .social(providerInfo)))
                self.view?.update(with: .success)
            case SignInError.existingEmail(_, let email):
                self.view?.update(with: .existingEmail(email: email ?? ""))
            case SignInError.noEmail(provider: _):
                self.view?.update(with: .noEmail)
            default:
                self.view?.update(with: .error)
            }
        }
    }

    @objc private func didAuthCodeReceive(_ notification: NSNotification) {
        print("social auth: auth code received")

        // TODO: async?
        view?.dismissWebController()

        self.analytics.send(.socialAuthDidReceiveCode)
        auth(with: notification.userInfo?["code"] as? String ?? "")
    }

    private func auth(with code: String) {
        view?.state = .loading

        let providerInfo = self.pendingAuthProviderInfo

        authAPI.signInWithCode(code).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationsRegistrationService().renewDeviceToken()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            if let pendingAuthProviderInfo = self.pendingAuthProviderInfo {
                if user.didJustRegister {
                    self.analytics.send(.signUpSucceeded(source: .social(pendingAuthProviderInfo)))
                } else {
                    self.analytics.send(.signInSucceeded(source: .social(pendingAuthProviderInfo)))
                }
            }
            self.pendingAuthProviderInfo = nil

            self.view?.update(with: .success)
            return self.notificationStatusesAPI.retrieve()
        }.done { result in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { error in
            switch error {
            case is NetworkError:
                print("social auth: successfully signed in, but could not get user")
                if let providerInfo = providerInfo {
                    self.analytics.send(.signInSucceeded(source: .social(providerInfo)))
                }
                self.view?.update(with: .success)
            case SignInError.badConnection:
                self.view?.update(with: .badConnection)
            default:
                self.view?.update(with: .error)
            }
        }
    }
}
