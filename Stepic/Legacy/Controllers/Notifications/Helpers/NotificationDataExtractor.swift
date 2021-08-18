//
//  NotificationDataExtractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class NotificationDataExtractor {
    private var text: String
    private var type: NotificationType

    // Extract id from strings: "/users/100000" -> 100000
    lazy var userID: Int? = {
        guard self.type == .comments else {
            return nil
        }

        if let link = HTMLParsingUtil.getLink(self.text, index: 0) {
            if let slashPos = link.lastIndexOf("/") {
                let startIndex = link.index(link.startIndex, offsetBy: slashPos + 1)
                let userIdString = link.substring(with: startIndex..<link.endIndex)
                return Int(userIdString)
            }
        }
        return nil
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
