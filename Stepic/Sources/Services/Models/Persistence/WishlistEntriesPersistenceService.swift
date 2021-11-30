import Foundation
import PromiseKit

protocol WishlistEntriesPersistenceServiceProtocol: AnyObject {
    func fetchAll() -> Guarantee<[WishlistEntryEntity]>
    func fetch(courseID: Course.IdType) -> Guarantee<WishlistEntryEntity?>

    func save(wishlistEntries: [WishlistEntryPlainObject]) -> Guarantee<Void>
    func saveNewWishlistEntries(_ wishlistEntries: [WishlistEntryPlainObject]) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
    func deleteWishlistEntry(courseID: Course.IdType) -> Guarantee<Void>
}

final class WishlistEntriesPersistenceService: BasePersistenceService<WishlistEntryEntity>,
                                               WishlistEntriesPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType) -> Guarantee<WishlistEntryEntity?> {
        self.fetch(courseID: courseID).map(\.first)
    }

    func save(wishlistEntries: [WishlistEntryPlainObject]) -> Guarantee<Void> {
        if wishlistEntries.isEmpty {
            return .value(())
        }

        return Guarantee { seal in
            self.fetch(ids: wishlistEntries.map(\.id)).done { cachedWishlistEntities in
                let cachedWishlistEntitiesMap = Dictionary(
                    uniqueKeysWithValues: cachedWishlistEntities.map({ ($0.id, $0) })
                )

                self.managedObjectContext.performChanges {
                    for wishlistEntryToSave in wishlistEntries {
                        if let cachedWishlistEntity = cachedWishlistEntitiesMap[wishlistEntryToSave.id] {
                            cachedWishlistEntity.update(wishlistEntry: wishlistEntryToSave)
                        } else {
                            _ = WishlistEntryEntity.insert(
                                into: self.managedObjectContext,
                                wishlistEntry: wishlistEntryToSave
                            )
                        }
                    }

                    seal(())
                }
            }
        }
    }

    func saveNewWishlistEntries(_ wishlistEntries: [WishlistEntryPlainObject]) -> Guarantee<Void> {
        Guarantee { seal in
            firstly { () -> Guarantee<Void?> in
                Guarantee(self.deleteAll(), fallback: nil)
            }.done { _ in
                self.managedObjectContext.performChanges {
                    for wishlistEntryToSave in wishlistEntries {
                        _ = WishlistEntryEntity.insert(
                            into: self.managedObjectContext,
                            wishlistEntry: wishlistEntryToSave
                        )
                    }
                    seal(())
                }
            }
        }
    }

    func deleteWishlistEntry(courseID: Course.IdType) -> Guarantee<Void> {
        Guarantee { seal in
            firstly { () -> Guarantee<[WishlistEntryEntity]> in
                self.fetch(courseID: courseID)
            }.done { wishlistEntries in
                self.managedObjectContext.performChanges {
                    for wishlistEntry in wishlistEntries {
                        self.managedObjectContext.delete(wishlistEntry)
                    }
                    seal(())
                }
            }
        }
    }

    // MARK: Private API

    private func fetch(courseID: Course.IdType) -> Guarantee<[WishlistEntryEntity]> {
        Guarantee { seal in
            let request = WishlistEntryEntity.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(WishlistEntryEntity.managedCourseId),
                NSNumber(value: courseID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let wishlistEntries = try self.managedObjectContext.fetch(request)
                seal(wishlistEntries)
            } catch {
                print("WishlistEntriesPersistenceService :: \(#function) failed fetch with error = \(error)")
                seal([])
            }
        }
    }
}
