//
//  NotificationDataExtractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class NotificationDataExtractor {
    private var text: String
    private var type: NotificationType

    // Extract id from strings: "/users/100000" -> 100000
    lazy var userId: Int? = {
        guard self.type == .comments else {
            return nil
        }

        if let link = HTMLParsingUtil.getLink(self.text, index: 0) {
            if let slashPos = link.lastIndexOf("/") {
                let startIndex = link.characters.index(link.startIndex, offsetBy: slashPos + 1)
                let userIdString = link.substring(with: startIndex..<link.endIndex)
                return Int(userIdString)
            }
        }
        return nil
    }()

    // Remove spaces and new lines
    // For Comments add new line after name
    lazy var preparedText: String? = {
        let pText = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return pText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
    }()

    init(text: String, type: NotificationType) {
        self.text = text
        self.type = type
    }
}

/*

 //gets course id if it is available for the given notification type
 func getCourseId() -> Int? {
 return nil
 // FIXME: old notification

 //        if notification.type != .Learn {
 //            return nil
 //        } else {
 //            if let courseLink = HTMLParsingUtil.getLink(notification.htmlText, index: 0) {
 //                if let courseIdStartIndex = courseLink.lastIndexOf("-") {
 //                    let start = courseLink.characters.index(courseLink.startIndex, offsetBy: courseIdStartIndex + 1)
 //                    let end = courseLink.characters.index(courseLink.startIndex, offsetBy: courseLink.characters.count - 1)
 //                    let courseIdString = courseLink.substring(with: start ..< end )
 //                    return Int(courseIdString)
 //                }
 //            }
 //            return nil
 //        }
 }

 //gets the comments URL if it is available for the given notification type
 func getCommentsURL() -> URL? {
 return nil
 // FIXME: old notification

 //        if notification.type != .Comments {
 //            return nil
 //        } else {
 //            if let commentsLink = HTMLParsingUtil.getLink(notification.htmlText, index: 2) {
 //                print("\(StepicApplicationsInfo.stepicURL)\(commentsLink)")
 //                let urlString = StepicApplicationsInfo.stepicURL + commentsLink
 //                let u = URL(string: urlString)
 //                print(u ?? "")
 //                return u
 //            } else {
 //                return nil
 //            }
 //        }
 }
 }*/
