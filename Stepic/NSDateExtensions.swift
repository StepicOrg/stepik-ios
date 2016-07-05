//
//  NSDateExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension NSDate {
    func getStepicFormatString(withTime withTime: Bool = false) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeZone = .None
        if withTime {
            formatter.timeStyle = .ShortStyle
        }
        
        return formatter.stringFromDate(self)
    }
    
}

extension NSTimeInterval {
    init(timeString: String) {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if (formatter.dateFromString(timeString)?.timeIntervalSince1970) == nil {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        } 
        self = formatter.dateFromString(timeString)!.timeIntervalSince1970
    }
}