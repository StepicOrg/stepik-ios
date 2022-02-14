import CoreData
import Foundation
import StepikModel

final class WishlistEntryEntity: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [
            NSSortDescriptor(key: #keyPath(managedCreateDate), ascending: false),
            NSSortDescriptor(key: #keyPath(managedId), ascending: false)
        ]
    }
}

// MARK: - WishlistEntryEntity (PlainObject Support) -

extension WishlistEntryEntity {
    var plainObject: WishlistEntry {
        WishlistEntry(
            id: self.id,
            courseID: self.courseID,
            userID: self.userID,
            createDate: self.createDate,
            platform: self.platform
        )
    }

    static func insert(
        into context: NSManagedObjectContext,
        wishlistEntry: WishlistEntry
    ) -> WishlistEntryEntity {
        let entity: WishlistEntryEntity = context.insertObject()
        entity.update(wishlistEntry: wishlistEntry)
        return entity
    }

    func update(wishlistEntry: WishlistEntry) {
        self.id = wishlistEntry.id
        self.courseID = wishlistEntry.courseID
        self.userID = wishlistEntry.userID
        self.createDate = wishlistEntry.createDate
        self.platform = wishlistEntry.platform
    }
}
