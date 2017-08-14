//
//  FBSocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FBSocialSDKProvider: NSObject, SocialSDKProvider {

    public static let instance = FBSocialSDKProvider()

    let name = "facebook"

    private override init() {
        super.init()
    }

    func getAccessInfo(success successHandler: @escaping (String, String?) -> Void, error errorHandler: @escaping (SocialSDKError) -> Void) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["email"], from: nil, handler: {
            result, error in
            if error != nil {
                errorHandler(SocialSDKError.connectionError)
                return
            }
            guard let res = result else {
                errorHandler(SocialSDKError.connectionError)
                return
            }

            if res.isCancelled {
                errorHandler(SocialSDKError.accessDenied)
                return
            }
            if let t = res.token.tokenString {
                successHandler(t, nil)
                return
            }
        })
    }

}
