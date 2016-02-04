//
//  UIExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(hex:Int) {
        self.init(hex:hex, alpha:1.0)
    }
    
    public convenience init(hex:Int, alpha:CGFloat) {
        
        let red   = CGFloat((0xff0000 & hex) >> 16) / 255.0
        let green = CGFloat((0xff00   & hex) >> 8)  / 255.0
        let blue  = CGFloat(0xff      & hex)        / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func errorRedColor() -> UIColor {
        return UIColor(hex: 0xff0033)
    }
    
    class func stepicGreenColor() -> UIColor {
        return UIColor(hex: 0x66CC66)
    }
    
    class func backgroundColor() -> UIColor {
        return UIColor(white: 0.9, alpha: 1)
    }
    
    class func correctQuizBackgroundColor() -> UIColor {
        return UIColor(hex: 0xE9F9E9)
    }
    
    class func wrongQuizBackgroundColor() -> UIColor {
        return UIColor(hex: 0xF5EBF2)
    }
    
    class func peerReviewYellowColor() -> UIColor {
        return UIColor(hex: 0xFFFAE9)
    }
}
