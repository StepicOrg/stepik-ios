//
//  NotificationAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 02.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit 

class NotificationAlertConstructor {
    private init() {}
    static let sharedConstructor = NotificationAlertConstructor()
    
    func getNotificationAlertController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("EnableNotificationsTitle", comment: ""), message: NSLocalizedString("EnableNotificationsMessage", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Default, handler: {
            action in
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(UIApplication.sharedApplication())
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .Cancel, handler: {
            action in
        }))
        
        return alert
    }
    
    func getOpenCommentNotificationViaSafariAlertController(success: (Void->Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("NewCommentAlertTitle", comment: ""), message: NSLocalizedString("NewCommentAlertMessage", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Default, handler: {
            action in
            success()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {
            action in
        }))
        
        return alert
    }
}
