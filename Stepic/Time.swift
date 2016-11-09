//
//  Time.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Time {
    fileprivate static var d = [NSObject: Date]()
    static func tick(_ key: NSObject) {
        d[key] = Date()
    }
    static func tock(_ key: NSObject) {
        print("Timer value -> \(d[key]?.timeIntervalSinceNow ?? 322) for key -> \(key)")
    }
}
