//
//  ConnectionHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class ConnectionHelper : NSObject {
    
    private override init() {
        super.init()
        reachability = Reachability.reachabilityForInternetConnection()
        reachability.reachableOnWWAN = defaults.objectForKey(reachableOnWWANKey) as! Bool
        
        reachability.reachableBlock = {
            reach in 
            
        }
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
//        reachability.startNotifier()
    }
    
    var reachabilityChanged : [(Bool -> Void)] = []
    
    func reachabilityChanged(notification: NSNotification) {
        if self.reachability.isReachableViaWiFi() || self.reachability.isReachableViaWWAN() {
            print("Service avalaible!!!")
        } else {
            print("No service avalaible!!!")
        }
    }
    
    static let shared = ConnectionHelper()
    
    var reachability : Reachability!
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let reachableOnWWANKey = "rreachableOnWWAN" 
}