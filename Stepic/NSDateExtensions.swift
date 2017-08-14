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
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if (formatter.date(from: timeString)?.timeIntervalSince1970) == nil {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
        self = formatter.date(from: timeString)!.timeIntervalSince1970
    }
}
