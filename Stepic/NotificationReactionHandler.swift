//
//  NotificationReactionHandler.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Chooses the appropriate reaction to the notification click
 */
class NotificationReactionHandler {
    func handleNotificationWithUserInfo(userInfo: [NSObject: AnyObject], delegate: AppDelegate) {
        print("handler")
        print(userInfo)
        
        let alert = UIAlertController(title: "handler", message: "\(userInfo)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "", style: .Default, handler: nil))
        
    }
    
    
    
}