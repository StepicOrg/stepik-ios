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
        switch self {
        case .all: return NSLocalizedString("NotificationsAll", comment: "")
        case .learning: return NSLocalizedString("NotificationsLearning", comment: "")
        case .comments: return NSLocalizedString("NotificationsComments", comment: "")
        case .reviews: return NSLocalizedString("NotificationsReviews", comment: "")
        case .teaching: return NSLocalizedString("NotificationsTeaching", comment: "")
        case .other: return NSLocalizedString("NotificationsOther", comment: "")
        }
    }

    case all, learning, comments, reviews, teaching, other
}
