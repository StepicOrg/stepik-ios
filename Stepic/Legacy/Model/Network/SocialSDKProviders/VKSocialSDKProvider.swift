//
//  VKSocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import VK_ios_sdk

protocol VKSocialSDKProviderDelegate: AnyObject {
    func presentAuthController(_ controller: UIViewController)
}

final class VKSocialSDKProvider: NSObject, SocialSDKProvider {
    static let instance = VKSocialSDKProvider()

    weak var delegate: VKSocialSDKProviderDelegate?

    let name = "vk"

    private var sdkInstance: VKSdk

    private var successHandler: ((String, String?) -> Void)?
    private var errorHandler: ((SocialSDKError) -> Void)?

    override private init() {
        self.sdkInstance = VKSdk.initialize(withAppId: StepikApplicationsInfo.SocialInfo.AppIds.vk)
        super.init()
        self.sdkInstance.register(self)
        self.sdkInstance.uiDelegate = self
    }

    func getAccessInfo() -> Promise<SocialSDKCredential> {
        Promise { seal in
            self.getAccessInfo(
                success: { (token, emailOrNil) in
                    seal.fulfill(SocialSDKCredential(token: token, email: emailOrNil))
                },
                error: { error in
                    seal.reject(error)
                }
            )
        }
    }

    private func getAccessInfo(
        success successHandler: @escaping (String, String?) -> Void,
        error errorHandler: @escaping (SocialSDKError) -> Void
    ) {
        self.successHandler = successHandler
        self.errorHandler = errorHandler

        if VKSdk.isLoggedIn() {
            VKSdk.forceLogout()
        }

        VKSdk.authorize(["email"])
    }
}

extension VKSocialSDKProvider: VKSdkDelegate {
    /// Notifies about access error. For example, this may occurs when user rejected app permissions through VK.com
    func vkSdkUserAuthorizationFailed() {
        self.errorHandler?(SocialSDKError.accessDenied)
    }

    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let error = result.error {
            print(error)
            self.errorHandler?(SocialSDKError.connectionError)
        } else if let accessToken = result.token.accessToken {
            self.successHandler?(accessToken, result.token.email)
        }
    }
}

extension VKSocialSDKProvider: VKSdkUIDelegate {
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    }

    func vkSdkShouldPresent(_ controller: UIViewController) {
        self.delegate?.presentAuthController(controller)
    }
}
