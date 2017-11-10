//
//  FBSocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import PromiseKit

class FBSocialSDKProvider: NSObject, SocialSDKProvider {

    public static let instance = FBSocialSDKProvider()

    let name = "facebook"

    private override init() {
        super.init()
    }

    func getAccessInfo() -> Promise<(token: String, email: String?)> {
        return Promise { fulfill, reject in
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withReadPermissions: ["email"], from: nil, handler: {
                result, error in
                if error != nil {
                    reject(SocialSDKError.connectionError)
                    return
                }
                guard let res = result else {
                    reject(SocialSDKError.connectionError)
                    return
                }

                if res.isCancelled {
                    reject(SocialSDKError.accessDenied)
                    return
                }
                if let t = res.token.tokenString {
                    fulfill((token: t, email: nil))
                    return
                }
            })
        }
    }

}
