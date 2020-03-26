//
//  SkeletonViewAnimation.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.06.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

// For static and pulsation effects in the future
// TODO: extract colors
enum SkeletonViewAnimation {
    case sliding

    var animation: CAAnimation {
        switch self {
        case .sliding:
            let startPoint = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
            startPoint.fromValue = CGPoint(x: -1.0, y: 0.5)
            startPoint.toValue = CGPoint(x: 1.0, y: 0.5)

            let endPoint = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
            endPoint.fromValue = CGPoint(x: 0.0, y: 0.5)
            endPoint.toValue = CGPoint(x: 2.0, y: 0.5)

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [startPoint, endPoint]
            animationGroup.duration = 1.5
            animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            animationGroup.repeatCount = .infinity
            animationGroup.isRemovedOnCompletion = false

            return animationGroup
        }
    }
}
