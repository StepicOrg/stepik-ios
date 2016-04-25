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
        static let create : [String : String] = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(StepicAPI.shared.token!.accessToken)"
        ]
    }
}