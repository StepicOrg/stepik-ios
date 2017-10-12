//
//  Notification.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Notification: NSManagedObject, JSONInitializable {
    typealias idType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        htmlText = json["html_text"].stringValue
        time = Parser.sharedParser.dateFromTimedateJSON(json["time"])
        isMuted = json["is_muted"].boolValue
        isFavorite = json["is_favorite"].boolValue

        managedStatus = json["is_unread"].boolValue ? NotificationStatus.unread.rawValue : NotificationStatus.opened.rawValue
        managedType = json["type"].stringValue
        managedAction = json["action"].stringValue

        level = json["level"].stringValue
        priority = json["priority"].stringValue
    }

    func update(json: JSON) {
        initialize(json)
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].int
    }

    var json: [String: AnyObject] {
        let dict: [String: AnyObject] = [
            "id": id as AnyObject,
            "html_text": htmlText as AnyObject,
            "time": time as AnyObject,
            "is_unread": (status == .unread) as AnyObject,
            "is_muted": isMuted as AnyObject,
            "is_favorite": isFavorite as AnyObject,
            "type": type.rawValue as AnyObject,
            "action": action.rawValue as AnyObject,
            "level": level as AnyObject,
            "priority": priority as AnyObject
        ]
        return dict
    }
}

enum NotificationStatus: String {
    case unread = "unread"
    case read = "read"
    case opened = "opened"
}

enum NotificationType: String {
    var localizedName: String {
        let localizedNames: [NotificationType: String] = [
            .comments: NSLocalizedString("NotificationsComments", comment: ""),
            .review: NSLocalizedString("NotificationsReviews", comment: ""),
            .teach: NSLocalizedString("NotificationsTeaching", comment: ""),
            .`default`: NSLocalizedString("NotificationsOther", comment: ""),
            .learn: NSLocalizedString("NotificationsLearning", comment: "")
        ]
        return localizedNames[self] ?? "Unknown"
    }

    case comments = "comments"
    case learn = "learn"
    case `default` = "default"
    case review = "review"
    case teach = "teach"
}

enum NotificationAction: String {
    case opened = "opened"
    case replied = "replied"
    case softDeadlineApproach = "soft_deadline_approach"
    case hardDeadlineApproach = "hard_deadline_approach"
    case unknown = "unknown"
}
