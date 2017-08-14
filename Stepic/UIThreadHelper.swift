//
//  UIThreadHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct UIThread {
    static func performUI(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: {
            block()
        })
    }
}
