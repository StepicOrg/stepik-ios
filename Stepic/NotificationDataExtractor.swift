//
//  NotificationDataExtractor.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Extracts information from the given notification
 */
class NotificationDataExtractor {
    var notification : Notification
    
    
    init(notification : Notification) {
        self.notification = notification
    }
    
    
    //gets course id if it is available for the given notification type
    func getCourseId() -> Int? {
        if notification.type != .Learn {
            return nil
        } else {
            if let courseLink = HTMLParsingUtil.getLink(notification.htmlText, index: 0) {
                if let courseIdStartIndex = courseLink.lastIndexOf("-") {
                    let start = courseLink.startIndex.advancedBy(courseIdStartIndex + 1)
                    let end = courseLink.startIndex.advancedBy(courseLink.characters.count - 1)
                    let courseIdString = courseLink.substringWithRange(start ..< end ) 
                    return Int(courseIdString)
                }
            }
            return nil
        }
    }
    
    //gets the comments URL if it is available for the given notification type
    func getCommentsURL() -> NSURL? {
        if notification.type != .Comments {
            return nil
        } else {
            if let commentsLink = HTMLParsingUtil.getLink(notification.htmlText, index: 2) {
                return NSURL(string: "\(StepicApplicationsInfo.stepicURL)\(commentsLink)")
            }
            return nil
        }
    }
}