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
    func imageScaledTo(_ scale: CGFloat) -> UIImage {
        let image = self
        
        let size = image.size.applying(CGAffineTransform(scaleX: scale, y: scale))
//        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
