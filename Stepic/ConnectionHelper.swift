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
        reachability.reachableOnWWAN = reachableOnWWAN
        
//        reachability.reachableOnWWAN = defaults.objectForKey(reachableOnWWANKey) as? Bool ?? false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        reachability.startNotifier()
    }
    
    private var reachabilityChangedHandlers : [(Bool -> Void)] = []
    
    func instantiate() {}
    
    func addReachabilityChangedHandler(handler handler : Bool->Void) {
        reachabilityChangedHandlers += [handler]
    }
    
    private func callReachabilityhandlers(result: Bool) {
        for handler in reachabilityChangedHandlers {
            handler(result)
        }
    }
    
    var isReachable : Bool {
        return self.reachability.isReachableViaWiFi() || (self.reachability.isReachableViaWWAN() && self.reachability.reachableOnWWAN) 
    }
    
    var reachableOnWWAN : Bool {
        get {
            if let r = defaults.objectForKey(reachableOnWWANKey) as? Bool {
                return r
            } else {
                self.reachableOnWWAN = false
                return false
            }
        }
        
        set(value) {
            defaults.setObject(value, forKey: reachableOnWWANKey)
            defaults.synchronize()
            reachability.reachableOnWWAN = value
        }
    }
    
    
    
    func reachabilityChanged(notification: NSNotification) {
        if isReachable {
            print("Service avalaible!!!")
            callReachabilityhandlers(true)
        } else {
            CacheManager.sharedManager.cancelAll(completion: {
                completed, errors in 
                print("Cancelled \(completed) videos")
                if completed + errors != 0 {
                    UIThread.performUI({Messages.sharedManager.showCancelledDownloadMessage(count: completed)})
                }
                if errors != 0 { print("Cancelled \(completed+errors) dowloads with \(errors) errors") }
            })
            callReachabilityhandlers(false)
            print("Service unavaliable!!!")
        }
    }
    
    static let shared = ConnectionHelper()
    
    private var reachability : Reachability!
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let reachableOnWWANKey = "reachableOnWWAN" 
}