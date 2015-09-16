//
//  Parser.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Parser: NSObject {
    static var sharedParser = Parser()
    
    private override init() {}
    
    func dateFromTimedateJSON(json: JSON) -> NSDate? {
        if let date = json.string { 
            return NSDate(timeIntervalSince1970: NSTimeInterval(timeString: date))
        } else {
            return nil
        }
    }
}
