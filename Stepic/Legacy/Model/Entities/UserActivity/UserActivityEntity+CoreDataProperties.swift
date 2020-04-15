import CoreData
import Foundation

extension UserActivityEntity {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPinsArray: NSObject?

    @NSManaged var managedProfile: Profile?

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    static func fetchRequest() -> NSFetchRequest<UserActivityEntity> {
        NSFetchRequest<UserActivityEntity>(entityName: "UserActivityEntity")
    }

    var profile: Profile? {
        get {
            self.managedProfile
        }
        set {
            self.managedProfile = newValue
        }
    }
}
