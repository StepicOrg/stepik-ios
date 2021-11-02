import CoreData
import Foundation
import PromiseKit

protocol MobileTiersPersistenceServiceProtocol: AnyObject {
    func fetchAll() -> Guarantee<[MobileTier]>
    func fetch(id: MobileTier.IdType) -> Guarantee<MobileTier?>
    func fetch(ids: [MobileTier.IdType]) -> Guarantee<[MobileTier]>
    func fetch(courseID: Course.IdType) -> Guarantee<[MobileTier]>
    func fetch(coursesIDsWithPromoCodesNames: [(Course.IdType, String?)]) -> Guarantee<[MobileTier]>

    func save(mobileTiers: [MobileTierPlainObject]) -> Guarantee<[MobileTier]>

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

    func fetch(courseID: Course.IdType) -> Guarantee<[MobileTier]> {
        Guarantee { seal in
            let request = MobileTier.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(MobileTier.managedCourseId),
                NSNumber(value: courseID)
            )
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

    func save(mobileTiers: [MobileTierPlainObject]) -> Guarantee<[MobileTier]> {
        Guarantee { seal in
            firstly {
                self.fetch(ids: mobileTiers.map(\.id))
            }.map { cachedMobileTiers in
                Dictionary(cachedMobileTiers.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })
            }.done { cachedMobileTiersMap in
                self.managedObjectContext.performChanges {
                    var result = [MobileTier]()

                    for mobileTier in mobileTiers {
                        if let cachedMobileTier = cachedMobileTiersMap[mobileTier.id] {
                            cachedMobileTier.update(mobileTier: mobileTier)
                            result.append(cachedMobileTier)
                        } else {
                            let insertedMobileTier = MobileTier.insert(
                                into: self.managedObjectContext,
                                mobileTier: mobileTier
                            )
                            result.append(insertedMobileTier)
                        }
                    }

                    seal(result)
                }
            }
        }
    }

    private func makeMobileTierID(courseID: Course.IdType, promoCodeName: String?) -> String {
        let promoCodeID = promoCodeName != nil ? promoCodeName.require() : "None"
        return "\(courseID)-\(PaymentStore.appStore.intValue)-\(promoCodeID)".trimmed()
    }
}
