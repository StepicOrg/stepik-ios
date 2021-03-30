import CoreData
import Foundation
import SwiftyJSON

final class ExamSession: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    var isActive: Bool { self.timeLeft > 0 }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userId = json[JSONKey.user.rawValue].intValue
        self.sectionId = json[JSONKey.section.rawValue].intValue
        self.beginDate = Parser.dateFromTimedateJSON(json[JSONKey.beginDate.rawValue])
        self.endDate = Parser.dateFromTimedateJSON(json[JSONKey.endDate.rawValue])
        self.timeLeft = json[JSONKey.timeLeft.rawValue].floatValue
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    enum JSONKey: String {
        case id
        case user
        case section
        case beginDate = "begin_date"
        case endDate = "end_date"
        case timeLeft = "time_left"
    }
}
