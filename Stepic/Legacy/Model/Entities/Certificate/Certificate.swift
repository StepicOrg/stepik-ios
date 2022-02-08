import CoreData
import SwiftyJSON

final class Certificate: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    var isEditAllowed: Bool { self.editsCount < self.allowedEditsCount }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.issueDate = Parser.dateFromTimedateJSON(json[JSONKey.issueDate.rawValue])
        self.updateDate = Parser.dateFromTimedateJSON(json[JSONKey.updateDate.rawValue])
        self.grade = json[JSONKey.grade.rawValue].intValue
        self.type = CertificateType(rawValue: json[JSONKey.type.rawValue].stringValue) ?? .regular
        self.urlString = json[JSONKey.url.rawValue].string
        self.isPublic = json[JSONKey.isPublic.rawValue].bool
        self.isWithScore = json[JSONKey.isWithScore.rawValue].boolValue
        self.editsCount = json[JSONKey.editsCount.rawValue].intValue
        self.allowedEditsCount = json[JSONKey.allowedEditsCount.rawValue].intValue
    }

    enum CertificateType: String {
        case regular
        case distinction
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case issueDate = "issue_date"
        case updateDate = "update_date"
        case grade
        case type
        case url
        case isPublic = "is_public"
        case isWithScore = "is_with_score"
        case editsCount = "edits_count"
        case allowedEditsCount = "allowed_edits_count"
    }
}
