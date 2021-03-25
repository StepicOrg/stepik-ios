import Foundation
import SwiftyJSON

final class CourseRecommendation: JSONSerializable {
    var id: User.IdType = 0
    var courses: [Course.IdType] = []

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.courses = json[JSONKey.courses.rawValue].arrayValue.compactMap(\.int)
    }

    enum JSONKey: String {
        case id
        case courses
    }
}
