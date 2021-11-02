import CoreData
import Foundation

final class MobileTier: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = String

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: true)]
    }

    var isTiersEmpty: Bool {
        (self.priceTier?.isEmpty ?? true) && (self.promoTier?.isEmpty ?? true)
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
        entity.update(mobileTier: mobileTier)
        return entity
    }

    func update(mobileTier: MobileTierPlainObject) {
        self.id = mobileTier.id
        self.courseID = mobileTier.courseID
        self.priceTier = mobileTier.priceTier
        self.promoTier = mobileTier.promoTier
    }
}
