//
//  CAGradientLayer+Init.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    convenience init(colors: [UIColor], rotationAngle: CGFloat) {
        self.init()
        self.colors = colors.map { $0.cgColor }

        let angle: Float = Float(rotationAngle) / (2 * Float.pi)
        let startPointX = powf(sinf(2 * Float.pi * ((angle + 0.75) / 2)), 2)
        let startPointY = powf(sinf(2 * Float.pi * ((angle + 0) / 2)), 2)
        let endPointX = powf(sinf(2 * Float.pi * ((angle + 0.25) / 2)), 2)
        let endPointY = powf(sinf(2 * Float.pi * ((angle + 0.5) / 2)), 2)

        self.endPoint = CGPoint(x: CGFloat(endPointX), y: CGFloat(endPointY))
        self.startPoint = CGPoint(x: CGFloat(startPointX), y: CGFloat(startPointY))
    }
}
