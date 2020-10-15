import Foundation
import SwiftyJSON

final class VisitedCourse: JSONSerializable {
    typealias IdType = Int

    var id: IdType = 0
    var courseID: Course.IdType = 0

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.course.rawValue: self.courseID
        ]
    }

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
    }

    enum JSONKey: String {
        case id
        case course
    }
}
