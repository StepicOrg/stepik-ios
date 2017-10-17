//
//  NotificationsSection.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum NotificationsSection {
    var notificationType: NotificationType? {
        switch self {
        case .comments:
            return .comments
        case .teaching:
            return .teach
        case .reviews:
            return .review
        case .learning:
            return .learn
        case .other:
            return .`default`
        default:
            return nil
        }
    }

    var localizedName: String {
        let localizedNames: [NotificationsSection: String] = [
            .all: NSLocalizedString("NotificationsAll", comment: ""),
            .learning: NSLocalizedString("NotificationsLearning", comment: ""),
            .comments: NSLocalizedString("NotificationsComments", comment: ""),
            .reviews: NSLocalizedString("NotificationsReviews", comment: ""),
            .teaching: NSLocalizedString("NotificationsTeaching", comment: ""),
            .other: NSLocalizedString("NotificationsOther", comment: "")
        ]
        return localizedNames[self] ?? "Unknown"
    }

    case all, learning, comments, reviews, teaching, other
}
