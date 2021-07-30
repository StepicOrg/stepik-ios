import CoreData

final class UserActivityEntity: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }
}

// MARK: - UserActivityEntity (PlainObject Support) -

extension UserActivityEntity {
    var plainObject: UserActivity {
        UserActivity(id: self.id, pins: self.pins)
    }

    static func insert(into context: NSManagedObjectContext, userActivity: UserActivity) -> UserActivityEntity {
        let object: UserActivityEntity = context.insertObject()

        object.id = userActivity.id
        object.pins = userActivity.pins

        return object
    }
}
