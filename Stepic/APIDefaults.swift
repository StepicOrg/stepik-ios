//
//  APIDefaults.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

struct APIDefaults {
    struct headers {
        static var bearer: [String : String] {
            return bearer(AuthInfo.shared.token?.accessToken)
        }

        static func bearer(_ accessToken: String?) -> [String : String] {
            if let token = accessToken {
                return [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"
                ]
            } else {
                return [String: String]()
            }
        }
    }
}
