import Foundation
import SwiftyJSON

struct WishlistEntryPlainObject: JSONSerializable {
    let id: Int
    let courseID: Int
    let userID: Int
    let createDate: Date?
    let platform: String

    var platformType: PlatformType? { PlatformType(self.platform) }
}

extension WishlistEntryPlainObject {
    var json: JSON {
        [
            JSONKey.course.rawValue: self.courseID,
            JSONKey.platform.rawValue: self.platform
        ]
    }

    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.createDate = Parser.dateFromTimedateJSON(json[JSONKey.createDate.rawValue])
        self.platform = json[JSONKey.platform.rawValue].stringValue
    }

    func update(json: JSON) {}

    enum JSONKey: String {
        case id
        case course
        case user
        case createDate = "create_date"
        case platform
    }
}
