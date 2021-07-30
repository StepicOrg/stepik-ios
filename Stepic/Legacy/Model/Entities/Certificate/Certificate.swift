import CoreData
import SwiftyJSON

@objc
final class Certificate: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    enum CertificateType: String {
        case distinction = "distinction"
        case regular = "regular"
    }
    
    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userId = json[JSONKey.user.rawValue].intValue
        self.courseId = json[JSONKey.course.rawValue].intValue
        self.issueDate = Parser.dateFromTimedateJSON(json[JSONKey.issueDate.rawValue])
        self.updateDate = Parser.dateFromTimedateJSON(json[JSONKey.updateDate.rawValue])
        self.grade = json[JSONKey.grade.rawValue].intValue
        self.type = CertificateType(rawValue: json[JSONKey.type.rawValue].stringValue) ?? .regular
        self.urlString = json[JSONKey.url.rawValue].string
        self.isPublic = json[JSONKey.isPublic.rawValue].bool
        self.isWithScore = json[JSONKey.isWithScore.rawValue].boolValue
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
    }
}
