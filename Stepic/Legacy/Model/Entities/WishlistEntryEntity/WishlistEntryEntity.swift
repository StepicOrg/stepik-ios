import CoreData
import Foundation

final class WishlistEntryEntity: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedCreateDate), ascending: false)]
    }

    var platformType: PlatformType? { PlatformType(self.platform) }
}

// MARK: - WishlistEntryEntity (PlainObject Support) -

extension WishlistEntryEntity {
    var plainObject: WishlistEntryPlainObject {
        WishlistEntryPlainObject(
            id: self.id,
            courseID: self.courseID,
            userID: self.userID,
            createDate: self.createDate,
            platform: self.platform
        )
    }

    static func insert(
        into context: NSManagedObjectContext,
        wishlistEntry: WishlistEntryPlainObject
    ) -> WishlistEntryEntity {
        let entity: WishlistEntryEntity = context.insertObject()
        entity.update(wishlistEntry: wishlistEntry)
        return entity
    }

    func update(wishlistEntry: WishlistEntryPlainObject) {
        self.id = wishlistEntry.id
        self.courseID = wishlistEntry.courseID
        self.userID = wishlistEntry.userID
        self.createDate = wishlistEntry.createDate
        self.platform = wishlistEntry.platform
    }
}
