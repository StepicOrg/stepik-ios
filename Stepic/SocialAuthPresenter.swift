//
//  SocialAuthPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

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
    case success, error, existingEmail(email: String)
}

enum SocialAuthState {
    case normal, loading
}

class SocialAuthPresenter {
    weak var view: SocialAuthView?

    var stepicsAPI: StepicsAPI
    var authManager: AuthManager

    init(authManager: AuthManager, stepicsAPI: StepicsAPI, view: SocialAuthView) {
        self.authManager = authManager
        self.stepicsAPI = stepicsAPI
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

        if let provider = provider.socialSDKProvider {
            if let provider = provider as? VKSocialSDKProvider,
               let viewDelegate = view as? VKSocialSDKProviderDelegate {
                provider.delegate = viewDelegate
            }

            provider.getAccessInfo(success: { socialToken, email in
                AuthManager.oauth.signUpWith(socialToken: socialToken, email: email, provider: provider.name, success: { token in
                    AuthInfo.shared.token = token

                    // FIXME: we shouldn't have UI dependencies here...
                    NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)

                    self.stepicsAPI.retrieveCurrentUser(success: { user in
                        AuthInfo.shared.user = user
                        User.removeAllExcept(user)
                        self.view?.update(with: .success)
                    }, error: { _ in
                        print("social auth: successfully signed in, but could not get user")
                        self.view?.update(with: .success)
                    })
                }, failure: { error in
                    switch error {
                    case .existingEmail(_, let email):
                        self.view?.update(with: .existingEmail(email: email ?? ""))
                    default:
                        self.view?.update(with: .error)
                    }
                })
            }, error: { _ in
                print("social auth: error while social auth")
                self.view?.update(with: .error)
            })
        } else {
            view?.presentWebController(with: provider.registerURL)
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
        authManager.logInWithCode(code, success: { token in
            AuthInfo.shared.token = token

            // FIXME: we shouldn't have UI dependencies here...
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.shared)

            self.stepicsAPI.retrieveCurrentUser(success: { user in
                AuthInfo.shared.user = user
                User.removeAllExcept(user)

                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "social"])
                self.view?.update(with: .success)
            }, error: { _ in
                print("social auth: successfully signed in, but could not get user")
                
                AnalyticsReporter.reportEvent(AnalyticsEvents.Login.success, parameters: ["provider": "social"])
                self.view?.update(with: .success)
            })
        }, failure: { _ in
            self.view?.update(with: .error)
        })
    }
}
