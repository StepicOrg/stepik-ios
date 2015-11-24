//
//  AnalyticsHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Google

class AnalyticsHelper: NSObject {
    static var sharedHelper = AnalyticsHelper()
    private override init() {super.init()}
    
    func changeSignIn() {
        let tracker = GAI.sharedInstance().defaultTracker
        if let id = StepicAPI.shared.userId {
            tracker.set("&uid", value: "\(id)")
        } else {
            tracker.set("&uid", value: "")
        }
    }
    
    func sendSignedIn() {
        let tracker = GAI.sharedInstance().defaultTracker
        var res = [NSObject : AnyObject]()
        for (key, value) in GAIDictionaryBuilder.createEventWithCategory("UX", action: "User Sign In", label: "", value: 0).build() {
            res[key as! NSObject] = value
        }
        tracker.send(res)
    }
}
