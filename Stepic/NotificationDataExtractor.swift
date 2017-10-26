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

    // Extract course id
    lazy var courseId: Int? = {
        guard self.type == .learn else {
            return nil
        }

        if let courseLink = HTMLParsingUtil.getLink(self.text, index: 0) {
            if let courseIdStartIndex = courseLink.lastIndexOf("-") {
                let start = courseLink.characters.index(courseLink.startIndex, offsetBy: courseIdStartIndex + 1)
                let end = courseLink.characters.index(courseLink.startIndex, offsetBy: courseLink.characters.count - 1)
                let courseIdString = courseLink.substring(with: start..<end)
                return Int(courseIdString)
            }
        }
        return nil
    }()

    // Extract comments URL
    lazy var commentsURL: URL? = {
        guard self.type == .comments else {
            return nil
        }

        if let commentsLink = HTMLParsingUtil.getLink(self.text, index: 2) {
            let urlString = StepicApplicationsInfo.stepicURL + commentsLink
            return URL(string: urlString)
        } else {
            return nil
        }
    }()

    // Remove spaces and new lines
    lazy var preparedText: String? = {
        let pText = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return pText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
    }()

    init(text: String, type: NotificationType) {
        self.text = text
        self.type = type
    }
}
