//
//  SocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol SocialSDKProvider {
    var name: String { get }
    func getAccessInfo() -> Promise<SocialSDKCredential>
}

struct SocialSDKCredential {
    let token: String
    let identityToken: String?
    let email: String?
    let firstName: String?
    let lastName: String?

    init(
        token: String,
        identityToken: String? = nil,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        self.token = token
        self.identityToken = identityToken
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
}

enum SocialSDKError: Error {
    case connectionError
    case accessDenied
}
