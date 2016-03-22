//
//  TimeFormatHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class TimeFormatHelper: NSObject {
    private override init() {
        super.init()
    }
    
    static let sharedHelper = TimeFormatHelper()
    
    func getTimeStringFrom(time: NSTimeInterval) -> String {
        let dateComponentsFormatter = NSDateComponentsFormatter()
//        print("formatting time -> \(dateComponentsFormatter.stringFromTimeInterval(time))")
        let additionalFormat = time >= 60 ? "" : (time < 10 ? "0:0" : "0:")
        return "\(additionalFormat)\(time >= 60 ? dateComponentsFormatter.stringFromTimeInterval(time)! : "\(Int(time))" )" ?? "--:--:--"
    }
}
