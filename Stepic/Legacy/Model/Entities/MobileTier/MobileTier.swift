import CoreData
import Foundation

final class MobileTier: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = String

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: true)]
    }
}

// MARK: - MobileTier (PlainObject Support) -

extension MobileTier {
    var plainObject: MobileTierPlainObject {
        MobileTierPlainObject(
            id: self.id,
            courseID: self.courseID,
            priceTier: self.priceTier,
            promoTier: self.promoTier
        )
    }

    static func insert(into context: NSManagedObjectContext, mobileTier: MobileTierPlainObject) -> MobileTier {
        let entity: MobileTier = context.insertObject()

        entity.id = mobileTier.id
        entity.courseID = mobileTier.courseID
        entity.priceTier = mobileTier.priceTier
        entity.promoTier = mobileTier.promoTier

        return entity
    }
}
