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
    func getAccessInfo() -> Promise<(token: String, email: String?)>
}

enum SocialSDKError: Error {
    case connectionError, accessDenied
}
