//
//  VKSocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import VK_ios_sdk

class VKSocialSDKProvider : NSObject, SocialSDKProvider {
    
    public static let instance = VKSocialSDKProvider()
    
    let name = "vk"
    
    private var sdkInstance : VKSdk
    
    private override init() {
        sdkInstance = VKSdk.initialize(withAppId: "5628680")
        super.init()
        sdkInstance.register(self)
    }
    
    func getAccessToken(success successHandler: @escaping (String) -> Void, error errorHandler: @escaping (SocialSDKError) -> Void) {
        VKSdk.authorize(["email"])
        self.successHandler = successHandler
        self.errorHandler = errorHandler
    }
    
    fileprivate var successHandler : ((String) -> Void)? = nil
    fileprivate var errorHandler : ((SocialSDKError) -> Void)? = nil
}

extension VKSocialSDKProvider : VKSdkDelegate {
    /**
     Notifies about access error. For example, this may occurs when user rejected app permissions through VK.com
     */
    public func vkSdkUserAuthorizationFailed() {
        print()
        errorHandler?(SocialSDKError.accessDenied)
    }

    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let token = result.token.accessToken {
            successHandler?(token)
        } else {
            print(result.error)
            errorHandler?(SocialSDKError.connectionError)
        }
    }
}
