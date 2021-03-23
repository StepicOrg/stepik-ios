import CoreData
import Foundation

final class UserActivityEntity: NSManagedObject {
    typealias IdType = Int

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "UserActivityEntity", in: CoreDataHelper.shared.context)!
    }

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var pins: [Int] {
        get {
            self.managedPinsArray as? [Int] ?? []
        }
        set {
            self.managedPinsArray = NSArray(array: newValue)
        }
    }

    // MARK: Init

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }
}

// MARK: - UserActivityEntity (PlainObject Support) -

extension UserActivityEntity {
    var plainObject: UserActivity {
        UserActivity(id: self.id, pins: self.pins)
    }
}
