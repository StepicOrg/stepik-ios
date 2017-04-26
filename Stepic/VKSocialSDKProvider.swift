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
        sdkInstance = VKSdk.initialize(withAppId: StepicApplicationsInfo.SocialInfo.AppIds.vk)
        super.init()
        sdkInstance.register(self)
    }
    
    func getAccessToken(success successHandler: @escaping (String) -> Void, error errorHandler: @escaping (SocialSDKError) -> Void) {
        self.successHandler = successHandler
        self.errorHandler = errorHandler
        if VKSdk.isLoggedIn() {
            VKSdk.forceLogout()
        }
        VKSdk.authorize(["email"])
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
        if (result.error) != nil {
            print(result.error)
            errorHandler?(SocialSDKError.connectionError)
            return
        }
        if let token = result.token.accessToken {
            successHandler?(token)
            return
        } 
    }
}
