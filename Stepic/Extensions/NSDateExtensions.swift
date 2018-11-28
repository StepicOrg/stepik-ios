//
//  NSDateExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension Date {
    func getStepicFormatString(withTime: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .none
        if withTime {
            formatter.timeStyle = .short
        }

        return formatter.string(from: self)
    }

}

extension TimeInterval {
    init(timeString: String) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let dateFormats = ["yyyy-MM-dd'T'HH:mm:ss'Z'",
                           "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                           "yyyy-MM-dd'T'hh:mm:ss.SSS a'Z'"]

        for dateFormat in dateFormats {
            formatter.dateFormat = dateFormat
            if let timeInterval = formatter.date(from: timeString)?.timeIntervalSince1970 {
                self = timeInterval
                return
            }
        }

        self = formatter.date(from: timeString)!.timeIntervalSince1970
    }
}
