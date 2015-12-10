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
    
    func codeFromURL(url: NSURL) -> String? {
        return url.getKeyVals()?["code"]
    }
}

extension NSURL {
    func getKeyVals() -> Dictionary<String, String>? {
        var results = [String:String]()
        let keyValues = self.query?.componentsSeparatedByString("&")
        if keyValues?.count > 0 {
            for pair in keyValues! {
                let kv = pair.componentsSeparatedByString("=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
}
