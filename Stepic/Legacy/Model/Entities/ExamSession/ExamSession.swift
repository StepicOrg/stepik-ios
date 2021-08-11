import CoreData
import SwiftyJSON

final class ExamSession: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var isActive: Bool { self.timeLeft > 0 }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userId = json[JSONKey.user.rawValue].intValue
        self.sectionId = json[JSONKey.section.rawValue].intValue
        self.beginDate = Parser.dateFromTimedateJSON(json[JSONKey.beginDate.rawValue])
        self.endDate = Parser.dateFromTimedateJSON(json[JSONKey.endDate.rawValue])
        self.timeLeft = json[JSONKey.timeLeft.rawValue].floatValue
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
