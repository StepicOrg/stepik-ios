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
        
        if !StepicAPI.shared.isAuthorized {
            return
        }
        
        let notificationObject : [String: AnyObject] = userInfo["object"] as! [String: AnyObject]
        if let notification = Notification(dictionary: notificationObject) {
            switch notification.type {
            case NotificationType.Learn:
                handleLearnNotification(notification)
            case NotificationType.Comments:
                handleCommentsNotification(notification)
            default:
                return
            }
        }
    }
    
    private func handleLearnNotification(notification: Notification) {
        let extractor = NotificationDataExtractor(notification: notification)
        if let courseId = extractor.getCourseId() {
            //TODO: Add implementation here
        }
    }
    
    private func handleCommentsNotification(notification: Notification) {
        let extractor = NotificationDataExtractor(notification: notification)
        if let commentsURL = extractor.getCommentsURL() {
            //TODO: Add implementation here
        }
    }
    
}