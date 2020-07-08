import CoreData
import Foundation
import SwiftyJSON

final class CoursePurchase: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    required convenience init(json: JSON) {
        self.init()
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.isActive = json[JSONKey.isActive.rawValue].boolValue
        self.paymentID = json[JSONKey.payment.rawValue].intValue
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json[JSONKey.id.rawValue].int
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case isActive = "is_active"
        case payment
    }
}
