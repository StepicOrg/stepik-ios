//
//  APIDefaults.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation

enum APIDefaults {
    enum Configuration {
        static let defaultTimeoutIntervalForRequest: TimeInterval = 10

        static let increasedTimeoutIntervalForRequest: TimeInterval = 30
    }

    enum Headers {
        static var bearer: HTTPHeaders {
            self.bearer(AuthInfo.shared.token?.accessToken)
        }

        static func bearer(_ bearerToken: String?) -> HTTPHeaders {
            if let bearerToken = bearerToken {
                return [
                    .contentType("application/json"),
                    .authorization(bearerToken: bearerToken)
                ]
            } else {
                return .init()
            }
        }
    }
}
