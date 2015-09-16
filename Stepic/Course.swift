//
//  Course.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Course: NSObject {
    var title : String
    var courseDescription : String
    var beginDate : NSDate?
    var endDate : NSDate?
    var coverURLString : String
    
    init(json: JSON) {
        title = json["title"].stringValue
        courseDescription = json["description"].stringValue
        coverURLString = Constants.sharedConstants.stepicURLString + json["cover"].stringValue
        
        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date_source"])
        endDate = Parser.sharedParser.dateFromTimedateJSON(json["last_deadline"])
    }
    

    
}

extension NSTimeInterval {
    init(timeString: String) {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "'yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        self = formatter.dateFromString(timeString)!.timeIntervalSince1970
    }
}