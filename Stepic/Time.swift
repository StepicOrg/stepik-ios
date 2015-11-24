//
//  Time.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Time {
    private static var d = [NSObject: NSDate]()
    static func tick(key: NSObject) {
        d[key] = NSDate()
    }
    static func tock(key: NSObject) {
        print("Timer value -> \(d[key]?.timeIntervalSinceNow ?? 322) for key -> \(key)")
    }
}