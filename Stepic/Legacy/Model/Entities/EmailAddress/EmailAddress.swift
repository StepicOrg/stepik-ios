import CoreData
import SwiftyJSON

final class EmailAddress: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var json: JSON {
        [
            "id": self.id as AnyObject,
            "user": self.userID as AnyObject,
            "email": self.email as AnyObject,
            "is_verified": self.isVerified as AnyObject,
            "is_primary": self.isPrimary as AnyObject
        ]
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.userID = json["user"].intValue
        self.email = json["email"].stringValue
        self.isVerified = json["is_verified"].boolValue
        self.isPrimary = json["is_primary"].boolValue
    }
}
