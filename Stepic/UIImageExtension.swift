//
//  UIImageExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import ImageIO


extension UIImage {
    func imageScaledTo(scale: CGFloat) -> UIImage {
        let image = self
        
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(scale, scale))
        let hasAlpha = true
//        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}