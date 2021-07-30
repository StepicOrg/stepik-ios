import CoreData
import SwiftyJSON

final class CourseBeneficiary: NSManagedObject, ManagedObject, JSONSerializable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.percent = json[JSONKey.percent.rawValue].floatValue
        self.isValid = json[JSONKey.isValid.rawValue].boolValue
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case percent
        case isValid = "is_valid"
    }
}
