//
//  CodeInputAccessorySize.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum CodeInputAccessorySize {
    case small
    case big
    
    typealias SizeParams = (textSize: CGFloat, viewHeight: CGFloat)
    
    var realSizes : SizeParams {
        switch self {
        case .small:
            return (textSize: 13, viewHeight: 40)
        case .big:
            return (textSize: 17, viewHeight: 60)
        }
    }
}
