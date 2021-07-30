import CoreData
import SwiftyJSON

final class ProctorSession: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var isFinished: Bool {
        self.stopDate != nil || self.submitDate != nil
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userId = json[JSONKey.user.rawValue].intValue
        self.sectionId = json[JSONKey.section.rawValue].intValue
        self.createDate = Parser.dateFromTimedateJSON(json[JSONKey.createDate.rawValue])
        self.startUrl = json[JSONKey.startURL.rawValue].string
        self.stopUrl = json[JSONKey.stopURL.rawValue].string
        self.startDate = Parser.dateFromTimedateJSON(json[JSONKey.startDate.rawValue])
        self.stopDate = Parser.dateFromTimedateJSON(json[JSONKey.stopDate.rawValue])
        self.submitDate = Parser.dateFromTimedateJSON(json[JSONKey.submitDate.rawValue])
        self.comment = json[JSONKey.comment.rawValue].stringValue
        self.score = json[JSONKey.score.rawValue].floatValue
    }

    enum JSONKey: String {
        case id
        case user
        case section
        case createDate = "create_date"
        case startURL = "start_url"
        case stopURL = "stop_url"
        case startDate = "start_date"
        case stopDate = "stop_date"
        case submitDate = "submit_date"
        case comment
        case score
    }
}
