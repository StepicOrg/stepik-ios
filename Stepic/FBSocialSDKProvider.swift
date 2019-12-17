//
//  FBSocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import FBSDKLoginKit
import Foundation
import PromiseKit

final class FBSocialSDKProvider: NSObject, SocialSDKProvider {
    static let instance = FBSocialSDKProvider()

    let name = "facebook"

    override private init() {
        super.init()
    }

    func getAccessInfo() -> Promise<(token: String, email: String?)> {
        Promise { seal in
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["email"], from: nil, handler: { result, error in
                if error != nil {
                    seal.reject(SocialSDKError.connectionError)
                    return
                }

                guard let result = result else {
                    seal.reject(SocialSDKError.connectionError)
                    return
                }

                if result.isCancelled {
                    seal.reject(SocialSDKError.accessDenied)
                    return
                }

                if let token = result.token?.tokenString {
                    seal.fulfill((token: token, email: nil))
                    return
                }
            })
        }
    }
}
