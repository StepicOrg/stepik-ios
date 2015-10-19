//
//  NSDateExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension NSDate {
    func getStepicFormatString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeZone = .None
        
        
        return formatter.stringFromDate(self)
    }
}

