//
//  GCDThings.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

func delay(_ delay: Double, closure:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
