import CoreData
import PromiseKit
import SwiftyJSON

final class Notification: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var json: JSON {
        [
            "id": id as AnyObject,
            "html_text": htmlText as AnyObject,
            "is_unread": (status == .unread) as AnyObject,
            "is_muted": isMuted as AnyObject,
            "is_favorite": isFavorite as AnyObject,
            "type": type.rawValue as AnyObject,
            "action": action.rawValue as AnyObject,
            "level": level as AnyObject,
            "priority": priority as AnyObject
        ]
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.htmlText = json["html_text"].stringValue
        self.time = Parser.dateFromTimedateJSON(json["time"])
        self.isMuted = json["is_muted"].boolValue
        self.isFavorite = json["is_favorite"].boolValue

        self.managedStatus = json["is_unread"].boolValue
            ? NotificationStatus.unread.rawValue
            : NotificationStatus.read.rawValue
        self.managedType = json["type"].stringValue
        self.managedAction = json["action"].stringValue

        self.level = json["level"].stringValue
        self.priority = json["priority"].stringValue
    }
}

enum NotificationStatus: String {
    case unread = "unread"
    case read = "read"
}

enum NotificationType: String {
    case comments = "comments"
    case learn = "learn"
    case `default` = "default"
    case review = "review"
    case teach = "teach"

    var localizedName: String {
        switch self {
        case .comments:
            return NSLocalizedString("NotificationsComments", comment: "")
        case .review:
            return NSLocalizedString("NotificationsReviews", comment: "")
        case .teach:
            return NSLocalizedString("NotificationsTeaching", comment: "")
        case .`default`:
            return NSLocalizedString("NotificationsOther", comment: "")
        case .learn:
            return NSLocalizedString("NotificationsLearning", comment: "")
        }
    }
}

enum NotificationAction: String {
    case opened = "opened"
    case replied = "replied"
    case softDeadlineApproach = "soft_deadline_approach"
    case hardDeadlineApproach = "hard_deadline_approach"
    case unknown = "unknown"
    case issuedCertificate = "issued_certificate"
}
