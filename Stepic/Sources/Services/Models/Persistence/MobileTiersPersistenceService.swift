import CoreData
import Foundation
import PromiseKit

protocol MobileTiersPersistenceServiceProtocol: AnyObject {
    func fetch(id: MobileTier.IdType) -> Guarantee<MobileTier?>
    func fetch(ids: [MobileTier.IdType]) -> Guarantee<[MobileTier]>
    func fetch(coursesIDsWithPromoCodesNames: [(Course.IdType, String?)]) -> Guarantee<[MobileTier]>

    func save(mobileTiers: [MobileTierPlainObject]) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

extension MobileTiersPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType, promoCodeName: String?) -> Guarantee<MobileTier?> {
        self.fetch(coursesIDsWithPromoCodesNames: [(courseID, promoCodeName)]).map(\.first)
    }
}

final class MobileTiersPersistenceService: BasePersistenceService<MobileTier>, MobileTiersPersistenceServiceProtocol {
    func fetch(id: MobileTier.IdType) -> Guarantee<MobileTier?> {
        self.fetch(ids: [id]).map(\.first)
    }

    func fetch(ids: [MobileTier.IdType]) -> Guarantee<[MobileTier]> {
        Guarantee { seal in
            let request = MobileTier.sortedFetchRequest

            let idPredicates = ids.map { NSPredicate(format: "%K LIKE[c] %@", #keyPath(MobileTier.managedId), $0) }
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: idPredicates)
            request.returnsObjectsAsFaults = false

            do {
                let mobileTiers = try self.managedObjectContext.fetch(request)
                seal(mobileTiers)
            } catch {
                print("MobileTiersPersistenceService :: \(#function) failed fetch with error = \(error)")
                seal([])
            }
        }
    }

    func fetch(coursesIDsWithPromoCodesNames: [(Course.IdType, String?)]) -> Guarantee<[MobileTier]> {
        let ids = coursesIDsWithPromoCodesNames.map(self.makeMobileTierID(courseID:promoCodeName:))
        return self.fetch(ids: ids)
    }

    func save(mobileTiers: [MobileTierPlainObject]) -> Guarantee<Void> {
        firstly {
            self.fetch(ids: mobileTiers.map(\.id))
        }.map { cachedMobileTiers in
            Dictionary(cachedMobileTiers.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })
        }.done { cachedMobileTiersMap in
            self.managedObjectContext.performChanges {
                for mobileTier in mobileTiers {
                    if let cachedMobileTier = cachedMobileTiersMap[mobileTier.id] {
                        cachedMobileTier.update(mobileTier: mobileTier)
                    } else {
                        _ = MobileTier.insert(into: self.managedObjectContext, mobileTier: mobileTier)
                    }
                }
            }
        }
    }

    private func makeMobileTierID(courseID: Course.IdType, promoCodeName: String?) -> String {
        let promoCodeID = promoCodeName != nil ? promoCodeName.require() : "None"
        return "\(courseID)-\(PaymentStore.appStore.intValue)-\(promoCodeID)".trimmed()
    }
}
