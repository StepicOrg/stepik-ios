//
//  SocialSDKProvider.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol SocialSDKProvider {
    var name: String { get }
    func getAccessToken(success successHandler: @escaping (String) -> Void, error errorHandler: @escaping (SocialSDKError) -> Void)
}

enum SocialSDKError : Error {
    case connectionError, accessDenied
}
