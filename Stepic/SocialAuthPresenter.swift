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

protocol SocialAuthView: class {
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

class SocialAuthPresenter {
    weak var view: SocialAuthView?

    var stepicsAPI: StepicsAPI
    var authAPI: AuthAPI
    var notificationStatusesAPI: NotificationStatusesAPI
    var splitTestingService: SplitTestingServiceProtocol

    var pendingAuthProviderInfo: SocialProviderInfo?

    var socialAuthHeaderString: String {
        return NSLocalizedString("SignInTitleSocial", comment: "")
    }

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, notificationStatusesAPI: NotificationStatusesAPI, splitTestingService: SplitTestingServiceProtocol, view: SocialAuthView) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.notificationStatusesAPI = notificationStatusesAPI
        self.splitTestingService = splitTestingService
        self.view = view

        // TODO: create NSNotification.Name extension
        NotificationCenter.default.addObserver(self, selector: #selector(self.didAuthCodeReceive(_:)), name: NSNotification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func update() {
        let providersInfo = SocialProvider.all.map { SocialProviderViewData(image: $0.info.image, name: $0.name, id: $0.rawValue) }
        view?.set(providers: providersInfo)
    }

    func logIn(with providerId: Int) {
        guard let provider = SocialProvider(rawValue: providerId)?.info else {
            print("social auth: provider with id = \(providerId) not found")
            self.view?.update(with: .error)
            return
        }

        self.pendingAuthProviderInfo = provider

        guard let SDKProvider = provider.socialSDKProvider else {
            view?.presentWebController(with: provider.registerURL)
            return
        }

        if let SDKProvider = SDKProvider as? VKSocialSDKProvider,
           let viewDelegate = view as? VKSocialSDKProviderDelegate {
            SDKProvider.delegate = viewDelegate
        }

        SDKProvider.getAccessInfo().then { socialToken, email -> Promise<(StepicToken, AuthorizationType)> in
            self.authAPI.signUpWithToken(socialToken: socialToken, email: email, provider: SDKProvider.name)
        }.then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationsRegistrationService().registerForNotifications()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            if user.didJustRegister {
                AmplitudeAnalyticsEvents.SignUp.registered(source: provider.amplitudeName).send()
            } else {
                AmplitudeAnalyticsEvents.SignIn.loggedIn(source: provider.amplitudeName).send()
            }

            AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "social"])
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
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "social"])
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

        AnalyticsReporter.reportEvent(AnalyticsEvents.SignIn.Social.codeReceived, parameters: nil)
        auth(with: notification.userInfo?["code"] as? String ?? "")
    }

    private func auth(with code: String) {
        view?.state = .loading

        authAPI.signInWithCode(code).then { token, authorizationType -> Promise<User> in
            AuthInfo.shared.token = token
            AuthInfo.shared.authorizationType = authorizationType

            NotificationsRegistrationService().registerForNotifications()

            return self.stepicsAPI.retrieveCurrentUser()
        }.then { user -> Promise<NotificationsStatus> in
            AuthInfo.shared.user = user
            User.removeAllExcept(user)

            AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "social"])
            if let name = self.pendingAuthProviderInfo?.amplitudeName {
                if user.didJustRegister {
                    AmplitudeAnalyticsEvents.SignUp.registered(source: name).send()
                } else {
                    AmplitudeAnalyticsEvents.SignIn.loggedIn(source: name).send()
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
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "social"])
                self.view?.update(with: .success)
            case SignInError.badConnection:
                self.view?.update(with: .badConnection)
            default:
                self.view?.update(with: .error)
            }
        }
    }
}
