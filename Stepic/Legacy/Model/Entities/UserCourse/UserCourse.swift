import CoreData
import Foundation
import SwiftyJSON

final class UserCourse: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    var json: JSON {
        [
            JSONKey.isFavorite.rawValue: self.isFavorite,
            JSONKey.isArchived.rawValue: self.isArchived,
            JSONKey.course.rawValue: self.courseID
        ]
    }

    required convenience init(json: JSON) {
        self.init()
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.isFavorite = json[JSONKey.isFavorite.rawValue].boolValue
        self.isArchived = json[JSONKey.isArchived.rawValue].boolValue
        self.lastViewed = Parser.shared.dateFromTimedateJSON(json[JSONKey.lastViewed.rawValue]) ?? Date()
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json[JSONKey.id.rawValue].int
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case lastViewed = "last_viewed"
    }
}
